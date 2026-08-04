# Contributing Guide

This guide will explain our code style and rules.

## Basic info

If you are a new contributor, check some Issues with the `good first issue` tag. These issues are great for new contributors. Our codebase is pretty small anyway so reading it should be simple.

Build an ISO: https://docs.redroselinux.org/#/build-your-own-image

## AI

We use Coderabbit for code reviews. Please do not vibecode your PRs. We are totally fine with assistance like removing repetitive work, for example:

- Putting a multiline string into a `#define`
- Writing a header file for a `.c` file
- Writing docstrings (but please read them first!)

...or asking for usage of a function, for example:

- Prompt: how to get all block devices in C?
- Prompt: how to use the `execvp` function?

We do not like pure slop. We once got a PR from an AI bot fixing a slight vulnerability, in a wrong way, which I think is just crazy.

## Code Style

We now prefer 2 space tabs. Some older code may use 4 space tabs.

## Submitting PRs

When you are submitting a PR, please, please explain what you did. I do not want a PR like:

```py
H #56
______________________________
No description provided.

-2157 +0
```

A good example:

```py
Added a Finished section to the installer #57
______________________________
Right now, it just says Press ENTER, but we should have a finished section, so I added it.
Included here:
- src/installer/tui.c/finished_header()
- src/installer/postinstgen.c/gen_postinst_scripts()
```

If a maintainer makes a PR that does not have this kind of description, it is fine, because we know what we are pushing.
