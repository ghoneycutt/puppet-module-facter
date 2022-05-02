# Contributing

Contributions are welcomed!

# Release process

1. update version in `metadata.json`
1. Update CHANGELOG.md with the following command replacing `--future-release` with appropriate value.
```
pdk bundle exec github_changelog_generator --user ghoneycutt --project puppet-module-facter --future-release v4.1.0
```
1. Update `REFERENCE.md` with the command `pdk bundle exec rake reference`
1. Commit changes and push to master
1. Tag the new version, such as `git tag -a 'v2.5.0' -m 'v2.5.0'`
1. Push tags `git push --tags`
1. Update the puppet strings documentation with `pdk bundle exec rake strings:gh_pages:update`
1. Clean up tests with `pdk bundle exec rake spec_clean`
1. Remove junit directory from beaker runs `rm -fr junit`
1. Build module with `pdk build`
1. Upload module to Puppet Forge.
