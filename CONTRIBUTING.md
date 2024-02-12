# Contribution Guideline

Thank you for getting interested in contribution to this project! We really appreciate it. 😊

Here is the guideline for contribution.

## Table of Contents

- [Submit Bug Reports or Feature Requests](#submit-bug-reports-or-feature-requests)
- [Translate the Project](#translate-the-project)
- [Propose Code Changes](#propose-code-changes)
    - [Coding Style](#coding-style)
    - [Documentation](#documentation)
- [Manage the Project](#manage-the-project)
    - [Release Flow](#release-flow)

## Submit Bug Reports or Feature Requests

- [Search for existing issues](https://github.com/ryonakano/pinit/issues) to check if it's a known issue.
- If it's not reported yet, [create a new issue](https://github.com/ryonakano/pinit/issues/new).

> [!TIP]
> If you are not used to do, [this section](https://docs.elementary.io/contributor-guide/feedback/reporting-issues#creating-a-new-issue-report) is for you.

## Translate the Project

We accept translations through Weblate:

- [pinit-app](https://hosted.weblate.org/projects/rosp/pinit-app/): Texts in the app itself
- [pinit-metainfo](https://hosted.weblate.org/projects/rosp/pinit-metainfo/): Texts in the desktop entry and the software center

Alternatively, you can fork this repository, edit the `*.po` files directly, and submit changes through pull requests.

## Propose Code Changes

We accepts changes to the source code through pull requests―even a small typo fix is welcome.

> [!TIP]
> Again, [the guideline by elementary](https://docs.elementary.io/contributor-guide/development/prepare-code-for-review) would be helpful here too.

### Coding Style

We follow [the coding style of elementary OS](https://docs.elementary.io/develop/writing-apps/code-style). Try to respect them.

### Documentation

We use documentation comments for clarifying interfaces (so-called "Black Box").

You can refer to them locally to help your coding and you should edit them if you change the internal behavior
or the interface of methods.

#### Refer to Existing Documentation Comments

Setting the build option `doc` to `true` will generate HTML documentations from the code.

Assuming that you're already build the project through the way described in the README:

```bash
cd builddir
meson configure -Ddoc=true
ninja
xdg-open builddir/doc/index.html
```

#### Editing Documentation Comments

You should edit documentation comments if you:

- change the internal behavior of existing methods.
- change the interface (parameters, the return value, etc.) of existing methods.
- add new methods, classes, structs, etc.

You should clarify the behavior, parameters, and the return value in case of methods. Here is an example:

```vala
/**
 * Returns true if this and other contains the same values.
 *
 * @param other Another DesktopFile.
 * @return true if this and other contains the same values.
 */
public bool equals (DesktopFile other) {
```

Refer to [Valadoc](https://valadoc.org/markup.htm) for markups.

## Manage the Project

### Release Flow
- Decide the version number of the release
    - Versioning should follow [Semantic Versioning](https://semver.org/)
- Create a new branch named `release-X.Y.Z` from the latest `origin/main` (`X.Y.Z` is the version number)
- See changes since the previous release: `git diff $(git describe --tags --abbrev=0)..release-X.Y.Z`
- Perform changes
    - Write a release note in `data/pinit.metainfo.xml.in`
        - Refer to [the Metainfo guidelines by Flathub](https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines/#release)
        - Credits contributors with their GitHub username
        - Translation contributors are excluded. Just writing `Update translations` is fine
    - Bump `version` in `meson.build`
    - Update screenshots if there are visual changes between releases
- Create a pull request with the above changes
- After merging it, [create a new release on GitHub](https://github.com/ryonakano/pinit/releases/new)
    - Create a new tag named `X.Y.Z`
    - Release title: `<Project Name> X.Y.Z Released`
    - It's fine to reuse the release note in the metainfo as the release description. Just convert XML to Markdown
- After publishing the release on GitHub, submit changes to [the Flathub repository](https://github.com/flathub/com.github.ryonakano.pinit)
    - Create a new branch named `release-X.Y.Z`
    - Change `url` and `sha256` in the manifest file
        - These two parameters point to the tar.gz of the release assets just we published on GitHub
- Create a new pull request with the above changes
- Merge the pull request once the build succeeded.
- The new release will be available on Flathub after some time
