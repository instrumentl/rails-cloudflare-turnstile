const { test, expect } = require("@playwright/test")

// Keep CI independent of Cloudflare availability. A shadow root models the part
// of a real widget that Turbo's cached DOM clone cannot preserve.
const api = `
  window.widgetCalls = { rendered: [], removed: [] }
  const widgets = new Map()
  window.turnstile = {
    render(element) {
      if (!/^[a-zA-Z0-9_-]{0,32}$/.test(element.dataset.action)) throw new Error("Invalid Cloudflare action")
      if ([...widgets.values()].some(widget => widget.element === element)) throw new Error("Duplicate widget")
      const id = "widget-" + (window.widgetCalls.rendered.length + 1)
      const host = document.createElement("div")
      host.attachShadow({mode: "closed"}).innerHTML = "<iframe title='Turnstile'></iframe>"
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "cf-turnstile-response"
      input.value = id
      element.append(host, input)
      widgets.set(id, {element, host, input})
      window.widgetCalls.rendered.push(id)
      window[element.dataset.callback]?.(id)
      return id
    },
    remove(id) {
      const widget = widgets.get(id)
      if (!widget) throw new Error("Removing unknown widget " + id)
      widget.host.remove()
      widget.input.remove()
      widgets.delete(id)
      window.widgetCalls.removed.push(id)
    }
  }
`
const apiUrl = "https://challenges.cloudflare.com/turnstile/**"

async function expectWidget(page, token) {
  const response = page.locator('input[name="cf-turnstile-response"]')
  await expect(response).toHaveCount(1)
  await expect(response).toHaveValue(token || /widget-\d+/)
  await expect(page.getByRole("button", { name: "Submit", exact: true })).toBeEnabled()
}

async function stream(page, action, method = "") {
  await page.evaluate(({ action, method }) => {
    const widget = document.querySelector("#widget").cloneNode(false)
    widget.dataset.theme = "dark"
    const target = method ? "widget" : "form"
    let html = widget.outerHTML
    if (!method) html = `<form id="form">${html}<button id="submit" disabled>Submit</button></form>`
    window.Turbo.renderStreamMessage(`<turbo-stream action="${action}" method="${method}" target="${target}"><template>${html}</template></turbo-stream>`)
  }, { action, method })
}

test.beforeEach(async ({ page }) => {
  await page.route(apiUrl, route => route.fulfill({ contentType: "text/javascript", body: api }))
  page.on("pageerror", error => { throw error })
})

test("Drive navigation and cached Back recreate one widget without reloading", async ({ page }) => {
  await page.goto("/")
  await expectWidget(page)
  const documentId = await page.evaluate(() => window.documentId)
  await page.getByRole("link", { name: "Next page" }).click()
  await expect(page).toHaveURL(/\/second$/)
  await expectWidget(page)
  await page.goBack()
  await expect(page).toHaveURL(/\/$/)
  await expectWidget(page)
  expect(await page.evaluate(() => window.documentId)).toBe(documentId)
  expect(await page.evaluate(() => widgetCalls.rendered.length - widgetCalls.removed.length)).toBe(1)
})

test("POST redirect renders the destination widget", async ({ page }) => {
  await page.goto("/")
  await expectWidget(page)
  await page.locator("#form").evaluate(form => form.dataset.turboFrame = "_top")
  await page.getByRole("button", { name: "Submit", exact: true }).click()
  await expect(page).toHaveURL(/\/second$/)
  await expectWidget(page)
})

test("frame navigation and stream replacement initialize new widgets", async ({ page }) => {
  await page.goto("/")
  await expectWidget(page)
  await page.getByRole("link", { name: "Next frame" }).click()
  await expect(page.locator("#frame")).toHaveAttribute("src", /frame-next/)
  await expect.poll(() => page.evaluate(() => widgetCalls.rendered.length)).toBe(2)
  await expectWidget(page)
  await stream(page, "replace")
  await expect.poll(() => page.evaluate(() => widgetCalls.rendered.length)).toBe(3)
  await expectWidget(page)
})

test("page refresh morphs recreate the widget and invoke its callback", async ({ page }) => {
  await page.goto("/")
  await expectWidget(page)
  const documentId = await page.evaluate(() => window.documentId)
  await page.evaluate(() => Turbo.renderStreamMessage('<turbo-stream action="refresh"></turbo-stream>'))
  await expect.poll(() => page.evaluate(() => widgetCalls.rendered.length)).toBe(2)
  await expectWidget(page, "widget-2")
  expect(await page.evaluate(() => widgetCalls.removed)).toEqual(["widget-1"])
  expect(await page.evaluate(() => window.documentId)).toBe(documentId)
})

test("stream morphs re-render with updated widget attributes", async ({ page }) => {
  await page.goto("/")
  await expectWidget(page)
  await stream(page, "replace", "morph")
  await expectWidget(page, "widget-2")
  await expect(page.locator("#widget")).toHaveAttribute("data-theme", "dark")
  expect(await page.evaluate(() => widgetCalls.removed)).toEqual(["widget-1"])
})

test("mock callbacks run once on initial load, Drive visits, frames, and morphs", async ({ page }) => {
  await page.goto("/?mock")
  await expectWidget(page, "mocked")
  expect(await page.evaluate(() => window.callbacks)).toEqual(["mocked"])
  await page.getByRole("link", { name: "Next page" }).click()
  await expect(page).toHaveURL(/second\?mock$/)
  await expectWidget(page, "mocked")
  await page.getByRole("link", { name: "Next frame" }).click()
  await expect.poll(() => page.evaluate(() => window.callbacks.length)).toBe(3)
  await page.evaluate(() => Turbo.renderStreamMessage('<turbo-stream action="refresh"></turbo-stream>'))
  await expect.poll(() => page.evaluate(() => window.callbacks.length)).toBe(4)
  await expectWidget(page, "mocked")
  expect(await page.evaluate(() => !!window.turnstile)).toBe(false)
})

test("hidden dialogs render on opening", async ({ page }) => {
  await page.goto("/?dialog")
  expect(await page.evaluate(() => widgetCalls.rendered)).toEqual([])
  await page.getByRole("button", { name: "Open dialog" }).click()
  await expectWidget(page)
})

test("reconnection during script loading cancels the earlier render", async ({ page }) => {
  let release
  const ready = new Promise(resolve => { release = resolve })
  await page.route(apiUrl, async route => {
    await ready
    await route.fulfill({ contentType: "text/javascript", body: api })
  })
  await page.goto("/", { waitUntil: "domcontentloaded" })
  await page.evaluate(async () => {
    const element = document.querySelector("#widget")
    const parent = element.parentElement
    element.remove()
    await new Promise(resolve => setTimeout(resolve, 0))
    parent.append(element)
    await new Promise(resolve => setTimeout(resolve, 0))
  })
  release()
  await expectWidget(page)
  expect(await page.evaluate(() => widgetCalls.rendered)).toEqual(["widget-1"])
})

test("visibility is checked again after a delayed script loads", async ({ page }) => {
  let release
  const ready = new Promise(resolve => { release = resolve })
  await page.route(apiUrl, async route => {
    await ready
    await route.fulfill({ contentType: "text/javascript", body: api })
  })
  await page.goto("/", { waitUntil: "domcontentloaded" })
  await page.locator("#form").evaluate(form => { form.hidden = true })
  release()
  await page.waitForLoadState("load")
  expect(await page.evaluate(() => widgetCalls.rendered)).toEqual([])
  await page.locator("#form").evaluate(form => { form.hidden = false })
  await expectWidget(page)
})
