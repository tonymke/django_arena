PIP_CONSTRAINTS_FILES ?=
PIP_REQUIREMENTS_FILES ?= 
PYTHON_VERSION_BIN ?= python3.10

SMOKE_ARGS ?= check  # functionally, ./manage.py check

.PHONY: all

all: virtualenv

.PHONY: check check-fmt check-lint check-type check-ungenerated-migrations check-test check-smoke 

check: check-fmt check-lint check-type check-test check-smoke

check-fmt: virtualenv
	.venv/bin/black --check src tests
	.venv/bin/isort --check src tests

check-lint: virtualenv
	.venv/bin/flake8 src tests

check-ungenerated-migrations: virtualenv
	.venv/bin/python -m arena makemigrations --check

check-type: virtualenv
	.venv/bin/mypy src tests

check-test: virtualenv
	.venv/bin/pytest

check-smoke: virtualenv
	.venv/bin/python -m arena $(SMOKE_ARGS)

.PHONY: clean clean-caches clean-packaging clean-virtualenv

clean: clean-caches clean-packaging clean-virtualenv

clean-caches:
	rm -rf .mypy_cache .pytest_cache
	find src tests -type d -name __pycache__ -exec rm -rf {} + || true

clean-packaging:
	rm -rf *.egg-info src/*.egg-info dist build

clean-virtualenv:
	rm -rf .venv

.PHONY: fmt

fmt: virtualenv
	.venv/bin/black src tests
	.venv/bin/isort src tests

.PHONY: virtualenv

virtualenv: .venv/pyvenv.cfg .venv/ynot_installed.txt

.venv/pyvenv.cfg:
	$(PYTHON_VERSION_BIN) -m venv --clear .venv

.venv/ynot_installed.txt: pyproject.toml $(PIP_CONSTRAINTS_FILES) $(PIP_REQUIREMENTS_FILES)
	sh -c ".venv/bin/pip freeze| sed -E 's/-e .*#egg=(.+)/\1/g' | sed -E 's/==.*//g' | xargs -r .venv/bin/pip uninstall -y"
	.venv/bin/pip install -e ".[dev]" $(foreach f,$(PIP_CONSTRAINTS_FILES),-c $(f)) $(foreach f,$(PIP_REQUIREMENTS_FILES),-r $(f))
	.venv/bin/pip freeze > "$@"
