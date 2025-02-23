PIP_INSTALL_CONSTRAINTS ?= constraints-django3.2.txt
PIP_INSTALL_FLAGS ?=
PYTHON_VERSION_BIN ?= python3.10

PIP_INSTALL_FLAGS += $(foreach file, $(PIP_INSTALL_CONSTRAINTS), -c $(file))

.PHONY: all

all: virtualenv

.PHONY: check check-fmt check-lint check-type check-test

check: check-fmt check-lint check-type check-test

check-fmt: virtualenv
	.venv/bin/black --check src tests
	.venv/bin/isort --check src tests

check-lint: virtualenv
	.venv/bin/flake8 src tests

check-type: virtualenv
	.venv/bin/mypy src tests

check-test: virtualenv
	.venv/bin/pytest

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

.venv/pyvenv.cfg: pyproject.toml $(PIP_INSTALL_CONSTRAINTS)
	$(PYTHON_VERSION_BIN) -m venv --clear .venv
	.venv/bin/pip install $(PIP_INSTALL_FLAGS) -e ".[dev]"
