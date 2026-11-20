# MAINTAINING

## Releasing a new version

1. Land any changes onto `main` as atomic commits
1. In a separate PR from any functional changes, update the CHANGELOG and `version.rb` file with the new version. Remember to run `bundle install` to also update `Gemfile.lock`
1. After that PR lands, create a signed git tag of the format `v0.x.y` (note that leading `v`) and push it
1. Once the tag is pushed, create a Release in the GitHub web UI. Include a summary of the changes from the CHANGELOG. This will trigger a GitHub Action to push to rubygems.

## Testing

Run `bundle exec rspec` and `bundle exec standardrb` for the Ruby code.

The browser suite runs the Stimulus controller directly from the README against
Turbo and Stimulus. It stubs Cloudflare's API so tests do not depend on external
challenge requests:

```sh
npm ci
npx playwright install chromium
npm test
```

To use an existing Chrome installation, set `CHROMIUM_PATH` to its executable.
The Node dependencies are only for development and are not shipped in the gem.
