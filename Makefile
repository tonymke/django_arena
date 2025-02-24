PYTHON_VERSION_BIN ?= python3.10

SMOKE_ARGS ?=

.PHONY: all

all: virtualenv

.PHONY: check check-fmt check-lint check-type check-test check-smoke

check: check-fmt check-lint check-type check-test check-smoke

check-fmt: virtualenv
	.venv/bin/black --check src tests
	.venv/bin/isort --check src tests

check-lint: virtualenv
	.venv/bin/flake8 src tests

check-type: virtualenv
	.venv/bin/mypy src tests

check-test: virtualenv
	.venv/bin/pytest

check-smoke: virtualenv
	.venv/bin/python -m arena $(SMOKE_ARGS)

.PHONY: clean clean-caches clean-packaging

clean: clean-caches clean-packaging

clean-caches:
	rm -rf .mypy_cache .pytest_cache
	find src tests -type d -name __pycache__ -exec rm -rf {} + || true

clean-packaging:
	rm -rf *.egg-info src/*.egg-info dist build

.PHONY: superclean superclean-virtualenv

superclean: clean superclean-virtualenv

superclean-virtualenv:
	rm -rf .venv

.PHONY: fmt

fmt: virtualenv
	.venv/bin/black src tests
	.venv/bin/isort src tests

.PHONY: virtualenv

virtualenv: .venv/pyvenv.cfg

.venv/pyvenv.cfg: pyproject.toml
	$(PYTHON_VERSION_BIN) -m venv --clear .venv
	.venv/bin/pip install -e ".[dev]"
