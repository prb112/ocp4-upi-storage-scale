# Release Process

Once a release of `ocp4-upi-storage-scale` is identified, the following steps are taken.

1. Update to the latest `main` branch `git checkout main; git pull`
2. Tag the `main` branch `git tag v0.0.1`
3. Push tags `git push --tags`
4. Update the Release Notes to indicate the changes made since the prior release.

These should be selected from the commits:

```
    feat: A new feature
    fix: A bug fix
    docs: Documentation only changes
    style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
    refactor: A code change that neither fixes a bug or adds a feature
    perf: A code change that improves performance
    test: Adding missing tests
    chore: Changes to the build process or auxiliary tools and libraries such as documentation generation
```

The release notes should include features and fixes and detailing any backward breaking changes.