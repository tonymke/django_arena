#!/bin/sh

set -e

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
if [ -z "${PROJECT_ROOT}" ]
then
    echo "project root not found" >&2
    exit 1
fi
cd "$PROJECT_ROOT"

set -x

.venv/bin/python -m black --check src tests
.venv/bin/python -m isort --check src tests
.venv/bin/python -m flake8 src tests
.venv/bin/python -m mypy src tests
.venv/bin/python -m pytest
