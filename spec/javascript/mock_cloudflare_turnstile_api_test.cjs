const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const path = require("node:path");
const { test } = require("node:test");
const vm = require("node:vm");

const source = readFileSync(path.join(__dirname, "../../app/assets/javascripts/mock_cloudflare_turnstile_api.js"), "utf8");

function widget({ callback, labels = [{ style: {}, innerHTML: "CAPTCHA goes here in production" }] } = {}) {
  return {
    dataset: callback === undefined ? {} : { callback },
    getElementsByTagName(name) {
      assert.equal(name, "p");
      return labels;
    }
  };
}

// Run the shipped asset with only the DOM and timer APIs it needs.
function load(widgets, globals = {}, readyState = "complete") {
  const timers = [];
  const listeners = {};
  const context = vm.createContext({
    ...globals,
    console: { log() {} },
    document: {
      readyState,
      getElementsByClassName(name) {
        assert.equal(name, "cf-turnstile");
        return widgets;
      },
      addEventListener(name, callback) {
        listeners[name] = callback;
      }
    },
    setTimeout(callback, delay) {
      assert.equal(delay, 1500);
      timers.push(callback);
    }
  });
  context.window = context;
  vm.runInContext(source, context);
  return {
    timers,
    listeners,
    complete() {
      assert.equal(timers.length, 1);
      timers.shift()();
    }
  };
}

test("updates the mock label without a callback", () => {
  const element = widget();
  load([element]).complete();
  const label = element.getElementsByTagName("p")[0];
  assert.equal(label.style.color, "green");
  assert.equal(label.innerHTML, "Mocked CAPTCHA succeeded");
});

test("passes the token as the callback's first argument", () => {
  const calls = [];
  load([widget({ callback: "onSuccess" })], {
    onSuccess: (...args) => calls.push(args)
  }).complete();
  assert.deepEqual(calls, [["mocked"]]);
});

test("handles widgets without labels and continues processing later widgets", () => {
  const calls = [];
  const last = widget({ callback: "onSuccess" });
  load([widget({ labels: [] }), widget({ labels: [], callback: "onSuccess" }), last], {
    onSuccess: (...args) => calls.push(args)
  }).complete();
  assert.deepEqual(calls, [["mocked"], ["mocked"]]);
  assert.equal(last.getElementsByTagName("p")[0].innerHTML, "Mocked CAPTCHA succeeded");
});

for (const name of ["label", "elem"]) {
  test(`resolves the global callback named ${name} and processes subsequent widgets`, () => {
    const calls = [];
    load([widget({ callback: name }), widget({ callback: "onSuccess" })], {
      [name]: token => calls.push([name, token]),
      onSuccess: token => calls.push(["onSuccess", token])
    }).complete();
    assert.deepEqual(calls, [[name, "mocked"], ["onSuccess", "mocked"]]);
  });
}

test("preserves namespaced callback expressions", () => {
  const calls = [];
  load([widget({ callback: "window.callbacks.onSuccess" })], {
    callbacks: { onSuccess: token => calls.push(token) }
  }).complete();
  assert.deepEqual(calls, ["mocked"]);
});

test("waits for DOMContentLoaded while the document is loading", () => {
  const element = widget();
  const page = load([element], {}, "loading");
  assert.equal(page.timers.length, 0);
  assert.equal(element.getElementsByTagName("p")[0].innerHTML, "CAPTCHA goes here in production");
  page.listeners.DOMContentLoaded();
  page.complete();
  assert.equal(element.getElementsByTagName("p")[0].innerHTML, "Mocked CAPTCHA succeeded");
});

test("schedules completion when the document is already interactive", () => {
  const element = widget();
  const page = load([element], {}, "interactive");
  assert.deepEqual(Object.keys(page.listeners), []);
  page.complete();
  assert.equal(element.getElementsByTagName("p")[0].innerHTML, "Mocked CAPTCHA succeeded");
});
