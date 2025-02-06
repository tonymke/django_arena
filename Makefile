rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

SRC := $(call rwildcard,arena,*.py)
TEST := $(call rwildcard,test,*.py)

PYTEST_FLAGS := -x
PYTHON_VERSION_BIN ?= python3.10

.PHONY: all

all: virtualenv check

.PHONY: check check-fmt check-lint check-type check-smoke

check: check-fmt check-lint check-type check-test check-smoke

check-fmt: virtualenv
	.venv/bin/black --check arena test
	.venv/bin/isort --profile black --check arena test

check-lint: virtualenv
	.venv/bin/flake8 arena test

check-type: virtualenv
	.venv/bin/mypy --strict arena test

check-test: virtualenv
	.venv/bin/pytest $(PYTEST_FLAGS) -W error::RuntimeWarning test/

check-smoke: virtualenv
	.venv/bin/python -m arena

.PHONY: clean clean-virtualenv clean-pycruft

clean: clean-caches clean-virtualenv

clean-caches:
	find arena test -type d -name __pycache__ -exec echo rm -rf {} +
	rm -rf .mypy_cache .pytest_cache

clean-virtualenv:
	rm -rf .venv

.PHONY: fmt

fmt: virtualenv
	.venv/bin/black arena test
	.venv/bin/isort --profile=black arena test

.PHONY: virtualenv

virtualenv: .venv/pyvenv.cfg

.venv/pyvenv.cfg: requirements.txt
	$(PYTHON_VERSION_BIN) -m venv --clear .venv
	.venv/bin/pip install -r requirements.txt
