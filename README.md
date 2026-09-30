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

## Overlay

Toggle the overlay with `omarchy-shell shell toggle mcwehner.pcalc`, or click
the bar button if you have added it. To use it in place of Omacalc, add this
to `~/.config/hypr/bindings.lua`:

```lua
-- Replace the default Omacalc bindings with pcalc
hl.unbind("SUPER + CTRL + Q")
hl.unbind("XF86Calculator")
o.bind("SUPER + CTRL + Q", "Calculator", "omarchy-shell shell toggle mcwehner.pcalc")
o.bind("XF86Calculator", "Calculator", "omarchy-shell shell toggle mcwehner.pcalc")
```

Then run `hyprctl reload` and check `hyprctl configerrors` to make sure it
applied cleanly.

- `enter` copies the selected representation and closes the overlay
- `tab` / `shift+tab` / arrow keys cycle between dec, hex, and bin
- `esc` closes the overlay

The overlay evaluates expressions with `bin/pcalc`. See [CLI](#cli) for
supported operators and literals.

## Bar widget

A calculator button on the bar toggles the overlay without a keybind:

```bash
omarchy bar put mcwehner.pcalc --section right
```

New installs with `--enable` place it on the right automatically. If the
overlay is already enabled and that command does nothing, add
`{ "id": "mcwehner.pcalc" }` to a `bar.layout` section in
`~/.config/omarchy/shell.json`. The shell reloads on save.

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

### Operators and literals

pcalc evaluates one arithmetic expression. Parentheses and Python operator
precedence apply. Integer results are limited to 4096 bits.

| Operators       | Meaning                                |
| --------------- | -------------------------------------- |
| `+` `-` `*` `/` | add, subtract, multiply, true division |
| `//` `%`        | floor division, modulo                 |
| `**`            | exponentiation (right-associative)     |
| `+x` `-x` `~`   | unary plus, minus, bitwise invert      |
| `&` `\|` `^`    | bitwise and, or, xor                   |
| `<<` `>>`       | left and right shift                   |

Literals: decimal integers, `0x` / `0b` / `0o` integers, and floats
(`1.5`, `2.5e1`).

True division (`/`) always yields a float. Bitwise operators require integers.
Function calls, comparisons, boolean `and` / `or` / `not`, and variables are
not supported.

### Output and flags

Integer results print three lines: decimal, hex (`0x…`), and binary (`0b…`).
Floats print a single decimal line (up to 12 significant digits).

`-j` / `--json` prints one JSON object. Success looks like
`{"ok":true,"dec":"4080","hex":"0xff0","bin":"0b111111110000"}`; floats omit
`hex` and `bin`. Failures print `{"ok":false,"error":"…"}` on stdout and exit 1.

`-c` / `--copy` `[dec|hex|bin]` copies one representation with `wl-copy`
(default: `dec`). Hex and bin are only available for integer results.

With no expression, a TTY starts a REPL (`:q`, `:quit`, or `:exit` to leave).
Otherwise the expression is read from stdin. Arguments are joined with spaces
(`pcalc 1 + 1`). Use `--` before an expression that starts with `-`.

## Removal

```bash
omarchy plugin remove mcwehner.pcalc
```

This disables the plugin, takes the bar button off the layout, and deletes
its folder. Then undo anything you added by hand:

- **Keybinding:** delete the pcalc lines from `~/.config/hypr/bindings.lua`,
  including the `hl.unbind(...)` lines, so the default Omacalc bindings come
  back. Run `hyprctl reload` and check `hyprctl configerrors`.
- **Bar widget:** if you added `{ "id": "mcwehner.pcalc" }` to
  `~/.config/omarchy/shell.json` by hand and it is still there, delete that
  entry.
- **CLI symlink:** `rm ~/.local/bin/pcalc`
