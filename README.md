# pcalc

A programmer-friendly calculator overlay for the Omarchy shell. Type an
expression and see the result in decimal, hex, and binary.

## Install

```bash
omarchy plugin add <git-url> --enable
```

Requires `python3` and `wl-copy` (from `wl-clipboard`).

## Usage

- `enter` copies the selected representation and closes the overlay
- `tab` / `shift+tab` / arrow keys cycle between dec, hex, and bin
- `esc` closes the overlay

Expressions support `+ - * / // % **`, bitwise `& | ^ ~ << >>`, parentheses,
and `0x` / `0b` / `0o` literals.

## CLI

The overlay is backed by `bin/pcalc`, which also works on its own:

```bash
bin/pcalc '0xff << 4 | 1'        # dec, hex, bin on separate lines
bin/pcalc --json -- '0xff << 4'  # JSON output
bin/pcalc -c hex '255'           # copy hex to the clipboard
bin/pcalc                        # interactive REPL
```

To put it on your `PATH`, symlink it:

```bash
ln -s ~/.config/omarchy/plugins/mcwehner.pcalc/bin/pcalc ~/.local/bin/pcalc
```
