(function() {
  function mock_cloudflare_turnstile_response() {
    setTimeout(function() {
      console.log("setting mock cloudflare turnstile to ✓");
      for (let elem of document.getElementsByClassName("cf-turnstile")) {
        // Update the label when present; callbacks also work without one.
        const label = elem.getElementsByTagName("p")[0];
        if (label) {
          label.style.color = 'green';
          label.innerHTML = "Mocked CAPTCHA succeeded";
        }
        if (elem.dataset.callback !== undefined) {
          // Resolve callbacks globally so widget locals cannot shadow their names.
          // Turnstile passes the token as the first argument.
          (0, eval)(elem.dataset.callback)("mocked");
        }
      }
    }, 1500);
  }

  if (document.readyState !== 'loading') {
    mock_cloudflare_turnstile_response()
  } else {
    document.addEventListener('DOMContentLoaded', mock_cloudflare_turnstile_response);
  }
})();
