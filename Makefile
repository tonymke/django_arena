MARKER_DIR := .make
PYTHON_DEP_MARKER := $(MARKER_DIR)/python_dep.makemarker
VIRTUALENV_MARKER := $(MARKER_DIR)/virtualenv.makemarker

DIRS :=
DIRS += $(MARKER_DIR)
MARKERS := $(PYTHON_DEP_MARKER) $(VIRTUALENV_MARKER)

DATABASE_FILE := db.sqlite3

SMOKE_ARGS ?= check  # functionally, ./manage.py check

MIGRATIONS_SRC := $(shell find src -type f -path '*/migrations/[0-9][0-9]*_[a-zA-Z0-9_]*.py')

.PHONY: all

all: base_config virtualenv database

VSCODE_DIR := .vscode
DIRS += $(VSCODE_DIR)

VSCODE_BASE_FILES := $(wildcard dev/conf/vscode/*.json)
VSCODE_TARGET_FILES := $(patsubst dev/conf/vscode/%, $(VSCODE_DIR)/%, $(VSCODE_BASE_FILES))

.PHONY: base_config

base_config: $(VSCODE_TARGET_FILES)

.vscode/%.json: dev/conf/vscode/%.json | $(VSCODE_DIR)
	[ -r "$@" ] || ln -s ../dev/conf/vscode/$*.json $@
	touch -c "$@"

.PHONY: check check-deps check-fmt check-lint check-type check-ungenerated-migrations check-test check-smoke

check: check-deps check-fmt check-lint check-type check-ungenerated-migrations check-test check-smoke

check-deps: virtualenv
	uv lock --check

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
	.venv/bin/python -m arena $(SMOKE_FLAGS)

.PHONY: clean clean-caches clean-markers clean-database clean-packaging

clean: clean-caches clean-markers clean-packaging

clean-caches:
	rm -rf .mypy_cache .pytest_cache
	find src tests -type d -name __pycache__ -exec rm -rf {} + || true

clean-markers:
	rm -f $(MARKERS)

clean-packaging:
	rm -rf *.egg-info src/*.egg-info dist build

clean-virtualenv-packages:
# Language serers really don't appreciate their virtualenv itself disappearing mid-process. Prefer cleaning out all packages by default
# Here we check if there is a venv, delete all packages. Otherwise do nothing - there is no need to make one just to do no emptying.
	sh -c "[ ! -r .venv/bin/pip ] || .venv/bin/pip freeze | sed -E 's/-e .*#egg=(.+)/\1/g' | sed -E 's/==.*//g' | xargs -r .venv/bin/pip uninstall -y"

.PHONY: superclean superclean-database superclean-virtualenv

superclean: clean superclean-database superclean-virtualenv

superclean-database:
	rm -f $(DATABASE_FILE)

superclean-virtualenv:
	rm -rf .venv

.PHONY: confclean confclean-vscode

confclean: confclean-vscode

confclean-vscode:
	rm -rf .vscode

.PHONY: fmt fmt-black fmt-isort

fmt: fmt-black fmt-isort

fmt-black: virtualenv
	.venv/bin/black src tests

fmt-isort: virtualenv
	.venv/bin/isort src tests

.PHONY: database

database: $(DATABASE_FILE)

db.sqlite3: $(MIGRATIONS_SRC) $(VIRTUALENV_MARKER) 
	.venv/bin/python -m arena migrate
	touch "$@"

.PHONY: virtualenv

virtualenv: $(PYTHON_DEP_MARKER) $(VIRTUALENV_MARKER)

$(PYTHON_DEP_MARKER): pyproject.toml uv.lock $(VIRTUALENV_MARKER) | $(MARKER_DIR)
	uv $(UV_FLAGS) sync
	touch "$@"

PYTHON_VERSION_BIN ?= python3.10
$(VIRTUALENV_MARKER): | $(MARKER_DIR)
	uv $(UV_FLAGS) venv --python $(PYTHON_VERSION_BIN) --seed $(UV_VENV_FLAGS)
	touch "$@"

$(DIRS):
	mkdir -p "$@"
