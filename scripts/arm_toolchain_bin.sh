#!/usr/bin/env bash
set -euo pipefail

required_tools=(arm-none-eabi-gcc arm-none-eabi-g++ arm-none-eabi-ar arm-none-eabi-ranlib arm-none-eabi-objcopy arm-none-eabi-size)
default_macos_toolchain_bases="/Applications/ArmGNUToolchain:/usr/local/ArmGNUToolchain"

has_complete_toolchain_bin() {
    local bin_dir="$1"

    for tool in "${required_tools[@]}"; do
        if [[ ! -x "${bin_dir}/${tool}" ]]; then
            return 1
        fi
    done

    # stdint.h is used as a lightweight signal that the target libc/newlib sysroot is installed.
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
    IFS=':' read -r -a arm_toolchain_bases <<< "${ARM_TOOLCHAIN_BASES:-${default_macos_toolchain_bases}}"
    for base in "${arm_toolchain_bases[@]}"; do
        for gcc_path in "${base}"/*/arm-none-eabi/bin/arm-none-eabi-gcc; do
            [[ -e "${gcc_path}" ]] || continue
            candidates+=("${gcc_path}")
        done
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
Install it with a Homebrew Arm GNU toolchain cask, for example:
  brew install --cask gcc-arm-embedded
If you already installed it in a custom location, set:
  ARM_TOOLCHAIN_BASES=/custom/path1:/custom/path2
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
