# Tests

CLI tests are a language-agnostic JSONL corpus plus a runner that only
invokes the binary. Point `$PCALC` at a port to run the same suite:

```bash
tests/run
JOBS=1 tests/run
PCALC=/path/to/other-pcalc tests/run
```

Requires `jq`. Default concurrency is `min(nproc, 8)`; set `JOBS` to override.
REPL, clipboard, and `--help` are out of scope.
