# Agent Instructions

These instructions apply to the entire repository.

This repository is a personal Django arena: a ready-to-go scratchpad for trying
ideas in a bootstrapped Django project. Keep changes pragmatic, local, and easy
to throw away or build on. Do not turn the arena into a production template
unless the user explicitly asks for that.

## Repository Shape

- `src/arena/` contains the Django project package.
- `src/arena/apps/core/` contains the starter app, including its templates and
    static assets.
- `tests/` contains the pytest suite.
- `dev/bin/check` is the canonical verification script.
- `dev/bin/autofmt` runs the project formatters.
- `pyproject.toml` is the source of truth for Python, Django, pytest, mypy,
    Black, isort, and flake8 configuration.

## Tooling

- Use `uv` for Python commands and dependency management. Prefer `uv run ...`
    over invoking globally installed tools.
- This project targets Python 3.10+ and Django 4.x.
- Prefer the lowest supported Python version that has a binary available on the
    machine. For example, use `uv sync --python python3.10` when Python 3.10 is
    available.
- Keep `uv.lock` in sync when dependencies change.
- Do not commit or rely on local scratch files such as `.venv/`, `db.sqlite3`,
    `.mypy_cache/`, or `.pytest_cache/`.

## Verification

Run the full check before handing back code changes when feasible:

```sh
dev/bin/check
```

That script runs:

- `uv lock --check`
- `uv run black --check src tests`
- `uv run isort --check src tests`
- `uv run flake8 src tests`
- `uv run mypy src tests`
- `uv run python manage.py check`
- `uv run python manage.py makemigrations --check --dry-run`
- `uv run pytest tests`

For quick iterations, use the narrower command that matches the change, then
finish with `dev/bin/check` if possible. If a check cannot be run or fails for
pre-existing reasons, report the command and the important failure output.

Use:

```sh
dev/bin/autofmt
```

to apply Black and isort formatting to `src` and `tests`.

## Code Style

- Follow the existing `src` layout and Django app structure.
- Keep Python typed enough for strict mypy. Add explicit return types and use
    Django request/response types where appropriate.
- Keep `from __future__ import annotations` in Python modules, matching the
    existing code.
- Black line length is 120. isort uses the Black profile.
- flake8 uses bugbear, B950, and the ignores configured in `pyproject.toml`.
- Migrations are skipped by Black/isort. When model changes require migrations,
    create the migration intentionally rather than editing generated files by
    hand.
- Keep shell scripts POSIX-friendly unless the script already requires
    something else.

## Django Notes

- Settings are development/scratchpad settings. Avoid adding production
    hardening, deployment layers, or environment indirection unless asked.
- The default database is local SQLite at the checkout root and is ignored by
    git.
- Prefer app-local templates and static files, as in `arena.apps.core`.
- If changing models, URLs, views, templates, or static assets, add or adjust
    focused tests under `tests/` when the behavior matters.

## Working Practice

- Read the nearby code before editing; this repo is small enough that local
    conventions should be obvious.
- Keep edits scoped to the user's request. Avoid broad refactors, dependency
    churn, or README expansion unless they directly support the task.
- Preserve user work in the tree. Do not revert unrelated changes.
- When introducing an experiment, make it easy for the next agent to understand
    how to run, test, or remove it.
