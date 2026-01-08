#!/bin/sh

set -eux

cd "$(dirname "$0")/../.."

uv lock --check
uv run black --check src tests
uv run isort --check src tests
uv run flake8 src tests
uv run mypy src tests
uv run python manage.py check
uv run python manage.py makemigrations --check --dry-run
uv run pytest tests
