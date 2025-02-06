PYTEST_FLAGS := -x
PYTHON_VERSION_BIN ?= python3.10

SMOKE_ARGS ?=

.PHONY: all

all: virtualenv check

.PHONY: check check-fmt check-lint check-type check-smoke check-smoke-pdb

check: check-fmt check-lint check-type check-test check-smoke

check-fmt: virtualenv
	.venv/bin/black -q --check src test
	.venv/bin/isort -q --check src test

check-lint: virtualenv
	.venv/bin/flake8 src test

check-type: virtualenv
	.venv/bin/mypy src test

check-test: virtualenv
	.venv/bin/pytest $(PYTEST_FLAGS) -W error::RuntimeWarning test

check-smoke: virtualenv
	.venv/bin/python -m arena $(SMOKE_ARGS)

check-smoke-pdb: virtualenv
	.venv/bin/python -m pdb -m arena $(SMOKE_ARGS)

.PHONY: clean clean-virtualenv clean-pycruft

clean: clean-caches clean-packaging clean-virtualenv

clean-caches:
	rm -rf .mypy_cache .pytest_cache
	find src test -type d -name __pycache__ -exec rm -rf {} + || true

clean-packaging:
	rm -rf *.egg-info src/*.egg-info dist build

clean-virtualenv:
	rm -rf .venv

.PHONY: fmt

fmt: virtualenv
	.venv/bin/black src test
	.venv/bin/isort src test

.PHONY: virtualenv

virtualenv: .venv/pyvenv.cfg .venv/bin/arena

.venv/pyvenv.cfg: requirements.txt
	$(PYTHON_VERSION_BIN) -m venv --clear .venv
	.venv/bin/pip install -r requirements.txt

.venv/bin/arena: .venv/pyvenv.cfg pyproject.toml
	.venv/bin/pip install -e .
