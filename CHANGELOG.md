ChangeLog
=========

0.4.2
-----
- various dependencies updates to address CVEs

0.4.1
-----
- bump net-imap, nokogiri, rack and rack-session dependencies to address CVEs
- fix for normal widget size (thanks @yenshirak)

0.4.0
-----
- add the ability to use explicit-render mode by passing `explicit: true` to `cloudflare_turnstile_script_tag` (thanks @adillari)
- adds the ability to set custom CSS classes on the turnstile element by passing `container_class:` to the `cloudflare_turnstile` helper (thanks @adillari)

0.3.1 (unreleased)
------------------
- bump rack dependency to address CVE

0.3.0
-----
- drop support for Ruby 3.1
- replace bundle-audit with bundler-audit
- support Rails 8.0.x

0.2.2
-----
- Resolve CVE-2025-27111
- Fix broken unit tests and update method documentation.
- Fix standardrb linting error.

0.2.1
-----
- Add support for passing arbitary keyword arguments to the underlying `content_tag` from the `cloudflare_turnstile` helper

0.2.0
-----
- drop support for Ruby 2.7
- drop support for Rails 5

0.1.6
-----
- support Rails 7.1.x (#87, thanks @AliOsm)
- an endless number of dependency bumps (thanks @dependabot)

0.1.5
-----
- allow configuring async and defer options of turnstile scripts

0.1.4
-----
- add data-callback support; mock javascript

0.1.3
-----
- Add mocked functionality in dev/test

0.1.2
-----
- Fix URIs in gemspec

0.1.1
-----
- Testing release for Github Actions integration
- Bump various build dependencies (thanks dependabot)

0.1.0
-----
- Initial release
