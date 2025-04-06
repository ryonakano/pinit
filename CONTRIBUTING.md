# Contribution Guideline
Thank you for getting interested in contributing to the project! We really appreciate it. 😊

## Submit Bug Reports or Feature Requests
1. [Search for existing issues](https://github.com/ryonakano/pinit/issues) to check if it's a known issue.
2. [Create a new issue](https://github.com/ryonakano/pinit/issues/new) if it's not reported yet.

> [!TIP]
> If you are not used to do, [this section](https://docs.elementary.io/contributor-guide/feedback/reporting-issues#creating-a-new-issue-report) is for you.

## Translate the Project
We accept translations through [Weblate](https://hosted.weblate.org/projects/rosp/pinit/).

Alternatively, you can fork this repository, edit the `*.po` files directly, and submit changes through pull requests.

## Propose Code Changes
We accept changes to the source code through pull requests. Even a small typo fix is welcome.

We follow [the coding style by elementary](https://docs.elementary.io/develop/writing-apps/code-style). Try to respect them.

> [!TIP]
> Again, [the guideline by elementary](https://docs.elementary.io/contributor-guide/development/prepare-code-for-review) would be helpful here too.

### Documentation
We use documentation comments for clarifying interfaces (so-called "Black Box").

You can refer to them locally to help your coding and you should edit them if you change the internal behavior
or the interface of methods.

#### Generate Documentation From Source Code
Building the source code with the option `doc` to `true` will generate HTML documentation.

You'll need the following extra dependencies to generate documentation:

* valadoc

Assuming that you've already built the project as written in the [README](README.md#from-source-code-native):

```bash
meson configure builddir -Ddoc=true
meson compile -C builddir
xdg-open builddir/valadoc/index.html
```

#### Edit Documentation Comments
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

Refer to [Valadoc](https://valadoc.org/markup.htm) for available markups.
