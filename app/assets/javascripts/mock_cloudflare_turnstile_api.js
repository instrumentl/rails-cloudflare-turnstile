(function() {
    function mock_cloudflare_turnstile_response() {
        setTimeout(function() {
            console.log("setting mock cloudflare turnstile to ✓");
            for (let elem of document.getElementsByClassName("cf-turnstile")) {
                elem.getElementsByTagName("p")[0].style.color = 'green';
                elem.getElementsByTagName("p").innerHTML = "Mocked CAPTCHA succeeded"
                if (elem.dataset.callback !== undefined) {
                    eval(elem.dataset.callback).call("mocked");
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
