SHELL :=/bin/bash -e -o pipefail
PWD   := $(shell pwd)

.DEFAULT_GOAL := all
.PHONY: all
all: ## build pipeline
all: mod inst gen build spell lint test

.PHONY: precommit
precommit: ## validate the branch before commit
precommit: all vuln

.PHONY: ci
ci: ## CI build pipeline
ci: lint-reports test govulncheck precommit diff

.PHONY: help
help:
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: ## setup the project
	@python3 -m venv venv
	@source venv/bin/activate
	@pip3 install -U pip && pip3 install -U wheel && pip3 install -U setuptools==59.5.0

.PHONY: get
get: ## get dependencies
	@pip3 install -r requirements.txt

.PHONY: docker-build
docker-build: ## build docker image
	@docker compose build

.PHONY: docker-up
up: ## start docker container
	@docker compose up -d

.PHONY: docker-down
down: ## stop docker container
	@docker compose down

.PHONY: diff
diff: ## git diff
	$(call print-target)
	@git diff --exit-code
	@RES=$$(git status --porcelain) ; if [ -n "$$RES" ]; then echo $$RES && exit 1 ; fi

define print-target
    @printf "Executing target: \033[36m$@\033[0m\n"
endef