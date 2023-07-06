#!/bin/bash

set -e

# Export PATH
export PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Install Poetry
curl -sSL https://install.python-poetry.org | python3 - && \
    poetry config virtualenvs.create false

# Install project dependencies
poetry install --no-root --no-dev

# Export GODOO_CONFIG variable
export GODOO_CONFIG="/usr/local/bin/conf.toml:$GODOO_CONFIG"

# Load completions for godoo
# source <(godoo completion bash)

# Use GODOO_CONFIG variable as an argument for godoo
exec /usr/local/bin/godoo completion bash "$@"

exit 1