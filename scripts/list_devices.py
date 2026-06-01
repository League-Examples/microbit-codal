#!/usr/bin/env python3

from __future__ import annotations

import shutil
import subprocess
import sys


def main() -> int:
    if shutil.which("pyocd") is None:
        print(
            "pyocd is not installed or not on PATH. Install it with `uv tool install pyocd` or `pipx install pyocd`.",
            file=sys.stderr,
        )
        return 1

    return subprocess.run(["pyocd", "list", "--probes"]).returncode


if __name__ == "__main__":
    raise SystemExit(main())
