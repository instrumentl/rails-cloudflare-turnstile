const { readFileSync } = require("node:fs")
const { createServer } = require("node:http")

// Exercise the copy-and-paste recipe itself, rather than a second controller implementation.
const readme = readFileSync("README.md", "utf8")
const controller = readme.match(/```js\n([\s\S]*?)```/)[1]
  .replace('"@hotwired/stimulus"', '"/stimulus.js"')
const assets = {
  "/controller.js": controller,
  "/stimulus.js": readFileSync("node_modules/@hotwired/stimulus/dist/stimulus.js"),
  "/turbo.js": readFileSync("node_modules/@hotwired/turbo/dist/turbo.es2017-esm.js"),
  "/application.js": `
    import { Application } from "/stimulus.js"
    import Controller from "/controller.js"
    import * as Turbo from "/turbo.js"
    window.Turbo = Turbo
    window.documentId = crypto.randomUUID()
    window.callbacks = []
    window.solved = token => {
      window.callbacks.push(token)
      document.querySelector("#submit").disabled = false
    }
    Application.start().register("turnstile", Controller)
  `
}

// Match the helper's real and mock markup; the Ruby specs cover HTML generation.
function widget(mock) {
  return `<div class="cloudflare-turnstile"><div id="widget" class="cf-turnstile"
    data-controller="turnstile" data-action="other" data-callback="solved"
    ${mock ? 'style="width:300px;height:65px"' : 'data-sitekey="1x00000000000000000000AA" data-size="normal" data-theme="auto"'}>
    ${mock ? '<input type="hidden" name="cf-turnstile-response" value="mocked"><p>CAPTCHA goes here in production</p>' : ""}
    </div></div>`
}

createServer((request, response) => {
  const url = new URL(request.url, "http://127.0.0.1:4386")
  if (assets[url.pathname]) {
    response.writeHead(200, { "Content-Type": "text/javascript" })
    response.end(assets[url.pathname])
    return
  }
  if (request.method === "POST") {
    response.writeHead(303, { Location: "/second" })
    response.end()
    return
  }
  const mock = url.searchParams.has("mock")
  const form = `<form id="form" action="/submit" method="post">${widget(mock)}<button id="submit" disabled>Submit</button></form>`
  response.writeHead(200, { "Content-Type": "text/html" })
  response.end(`<!doctype html><html><head>
    <meta name="turbo-refresh-method" content="morph">
    <script type="module" src="/application.js"></script>
    ${mock ? "" : '<script src="https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit" async defer></script>'}
    </head><body><h1>${url.pathname}</h1>
    <a href="/second${mock ? "?mock" : ""}">Next page</a>
    <button onclick="document.querySelector('dialog').showModal()">Open dialog</button>
    ${url.searchParams.has("dialog") ? `<dialog>${form}</dialog>` : `<turbo-frame id="frame"><a href="/frame-next${mock ? "?mock" : ""}">Next frame</a>${form}</turbo-frame>`}
    </body></html>`)
}).listen(4386, "127.0.0.1")
