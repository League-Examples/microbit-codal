set dotenv-load := true

default:
    @just --list

setup-macos:
    brew install --cask gcc-arm-embedded
    brew install uv
    echo "Using ARM toolchain at: $$(./scripts/arm_toolchain_bin.sh)"

setup-linux:
    sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi python3 python3-pip

arm-toolchain:
    ./scripts/arm_toolchain_bin.sh

uv-sync:
    uv venv
    uv sync

build:
    PATH="$$(./scripts/arm_toolchain_bin.sh):$$PATH" uv run python3 build.py

build-clean:
    PATH="$$(./scripts/arm_toolchain_bin.sh):$$PATH" uv run python3 build.py --clean

scripts-build:
    PATH="$$(./scripts/arm_toolchain_bin.sh):$$PATH" uv run python3 scripts/build.py

deploy *args='':
    uv run python3 scripts/deploy.py {{args}}

build-deploy *args='':
    PATH="$$(./scripts/arm_toolchain_bin.sh):$$PATH" uv run python3 scripts/build_and_deploy.py {{args}}
