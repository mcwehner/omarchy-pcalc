# pcalc

A programmer-friendly calculator overlay for the Omarchy shell. Type an
expression and see the result in decimal, hex, and binary.

## Install

```bash
omarchy plugin add https://github.com/mcwehner/omarchy-pcalc.git --enable
```

Requires `python3` and `wl-copy` (from `wl-clipboard`).

## Update

```bash
omarchy plugin update mcwehner.pcalc
```

Then run `omarchy restart shell` so the overlay picks up the new files. A CLI
symlink to the plugin folder does not need to be recreated.

## Keybinding

Toggle the overlay with `omarchy-shell shell toggle mcwehner.pcalc`. To use it
in place of Omacalc, add this to `~/.config/hypr/bindings.lua`:

```lua
-- Replace the default Omacalc bindings with pcalc
hl.unbind("SUPER + CTRL + Q")
hl.unbind("XF86Calculator")
o.bind("SUPER + CTRL + Q", "Calculator", "omarchy-shell shell toggle mcwehner.pcalc")
o.bind("XF86Calculator", "Calculator", "omarchy-shell shell toggle mcwehner.pcalc")
```

Then run `hyprctl reload` and check `hyprctl configerrors` to make sure it
applied cleanly.

## Usage

- `enter` copies the selected representation and closes the overlay
- `tab` / `shift+tab` / arrow keys cycle between dec, hex, and bin
- `esc` closes the overlay

Expressions support `+ - * / // % **`, bitwise `& | ^ ~ << >>`, parentheses,
and `0x` / `0b` / `0o` literals. Integer results are limited to 4096 bits.

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

## Removal

```bash
omarchy plugin remove mcwehner.pcalc
```

This disables the plugin and deletes its folder. Then undo anything you
added by hand:

- **Keybinding:** delete the pcalc lines from `~/.config/hypr/bindings.lua`,
  including the `hl.unbind(...)` lines, so the default Omacalc bindings come
  back. Run `hyprctl reload` and check `hyprctl configerrors`.
- **CLI symlink:** `rm ~/.local/bin/pcalc`
