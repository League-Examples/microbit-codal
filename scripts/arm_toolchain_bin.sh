#!/usr/bin/env bash
set -euo pipefail

required_tools=(arm-none-eabi-gcc arm-none-eabi-g++ arm-none-eabi-ar arm-none-eabi-ranlib arm-none-eabi-objcopy arm-none-eabi-size)

has_complete_toolchain_bin() {
    local bin_dir="$1"

    for tool in "${required_tools[@]}"; do
        if [[ ! -x "${bin_dir}/${tool}" ]]; then
            return 1
        fi
    done

    local sysroot
    sysroot="$("${bin_dir}/arm-none-eabi-gcc" -print-sysroot 2>/dev/null || true)"
    [[ -n "${sysroot}" && -f "${sysroot}/include/stdint.h" ]]
}

if command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    toolchain_bin="$(dirname "$(command -v arm-none-eabi-gcc)")"
    if has_complete_toolchain_bin "${toolchain_bin}"; then
        printf '%s\n' "${toolchain_bin}"
        exit 0
    fi
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    candidates=()
    for gcc_path in /Applications/ArmGNUToolchain/*/arm-none-eabi/bin/arm-none-eabi-gcc; do
        [[ -e "${gcc_path}" ]] || continue
        candidates+=("${gcc_path}")
    done

    if ((${#candidates[@]} > 0)); then
        while IFS= read -r gcc_path; do
            toolchain_bin="$(dirname "${gcc_path}")"
            if has_complete_toolchain_bin "${toolchain_bin}"; then
                printf '%s\n' "${toolchain_bin}"
                exit 0
            fi
        done < <(printf '%s\n' "${candidates[@]}" | sort -r)
    fi

    cat >&2 <<'EOF'
ARM embedded toolchain was not found.
Install it with:
  brew install --cask gcc-arm-embedded
Then run the build command again.
EOF
    exit 1
fi

cat >&2 <<'EOF'
ARM embedded toolchain was not found in PATH.
Install on Ubuntu/Debian with:
  sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi
EOF
exit 1
