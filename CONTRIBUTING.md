# Contributing Guide

This guide will explain our code style and rules.

## Basic info

If you are a new contributor, check some Issues with the `good first issue` tag. These issues are great for new contributors.

Building Redrose requires `make`, `gcc`, `grub-mkresue` and optionally `qemu`.
To build it, download the source:

```
git clone https://github.com/redroselinux/redroselinux
cd redroselinux
```

Next up, familiarize yourself with the instructions shown when running

```
make help
```

and when you're ready to build it, run

```
make
```

or 

```
make no-vm
```

## AI

If you use AI for assistance, that is fine, but include a comment like this one in `src/installer/main.c`:
```c
// was ai used in this file? yes (minor assistance)
```

**This comment needs to be on top of the file after imports.**

If you did use AI for more than just a bit of assistance, put in this:
```c
// was ai used in this file? yes (functions: this, that, that, then, h)
```

If you did not AT ALL, include:
```c
// was ai used in this file? no
```

### Boundaries between minor and major assistance

We define minor assistance as using AI for small, non-critical tasks, such as formatting, code suggestions, or helping with repetitive boilerplate. You can usually distinguish it from larger AI contributions by comparing prompts:

Minor assistance example:

> Please finish this migration for the rest of the code: [...]

More substantial AI usage example:

> add feat [...], pls maek it woekrk

If AI was used for more than minor assistance, you must list the affected functions in the AI comment.

## Code Style

- For all languages, use 4 spaces per 1 tab.

### C

#### Blocks

When you create a function:

```c
void my_function() {}
```

...NEVER EVER make a newline after the ).

If your function takes a lot of arguments, put each argument in its own line and indent one more time for the code, like in this func from `src/installer/postinstgen.c`:

```c
int gen_postinst_scripts(
    char* drive,
    char* username,
    char* userpassword,
    char* rootpassword,
    char* hostname) {
        // the code
}
```

#### Header text for sections in the installer

_Requires `src/installer/tui.c`_

When you print a big header, first install `figlet` and run:

```bash
figlet Header
```

Now choose a color for your header. This just, adds a little variety to it, perhaps?
- blue
- red
- yellow
- green

We will pick green for now.

Now print it like this:

```c
set_text_color(GREEN);
printf(
    "the figlet text"
    "h"
);set_text_color(RESET);
```

For any \ in the string, you must replace it with \\ so it gets properly shown.

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
