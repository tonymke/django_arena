#!/bin/sh

set -eux

cd "$(dirname "$0")/../.."

uv run black src tests
uv run isort src tests
