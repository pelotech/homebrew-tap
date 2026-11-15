# homebrew-tap TODO

Open follow-ups for this tap. Tick items off (or delete them) in the PR that resolves them.

## Nice to have (deferred review items)

- [ ] `scripts/test-bump-formula`: check stderr so the wrong-signer and missing-release cases prove
  their cause
- [ ] `scripts/bump-formula`: usage message; reject downgrades (newer-version-only)
- [ ] `scripts/outdated-formulae`: warn and continue per formula (do this before adding a 2nd
  formula)
- [ ] `bump.yaml`: rename the `app-id` input to `client-id`
- [ ] Optionally scope the App secret to a `main`-only environment
