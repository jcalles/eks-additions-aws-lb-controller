ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: help gen lint test _gen-main _gen-examples _gen-modules _lint-files _lint-fmt _lint-json _pull-tf _pull-tfdocs _pull-fl _pull-jl

CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
TF_EXAMPLES = $(sort $(dir $(wildcard $(CURRENT_DIR)examples/*/)))
TF_MODULES  = $(sort $(dir $(wildcard $(CURRENT_DIR)modules/*/)))

# -------------------------------------------------------------------------------------------------
# Container versions
# -------------------------------------------------------------------------------------------------
TF_VERSION      = light
TFDOCS_VERSION  = 0.6.0
FL_VERSION      = 0.2
JL_VERSION      = latest-0.4


# -------------------------------------------------------------------------------------------------
# Enable linter (file-lint, terraform fmt, jsonlint)
# -------------------------------------------------------------------------------------------------
LINT_FL_ENABLE = 1
LINT_TF_ENABLE = 1
LINT_JL_ENABLE = 1


# -------------------------------------------------------------------------------------------------
# terraform-docs defines
# -------------------------------------------------------------------------------------------------
# Adjust your delimiter here or overwrite via make arguments
DELIM_START = <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
DELIM_CLOSE = <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# What arguments to append to terraform-docs command
TFDOCS_ARGS = --sort-inputs-by-required --with-aggregate-type-defaults


# -------------------------------------------------------------------------------------------------
# Default target
# -------------------------------------------------------------------------------------------------
help:
	@echo "gen        Generate terraform-docs output and replace in README.md's"
	@echo "lint       Static source code analysis"
	@echo "test       Integration tests"


# -------------------------------------------------------------------------------------------------
# Standard targets
# -------------------------------------------------------------------------------------------------
gen: _pull-tfdocs
	@echo "################################################################################"
	@echo "# Terraform-docs generate"
	@echo "################################################################################"
	@$(MAKE) --no-print-directory _gen-main
	@$(MAKE) --no-print-directory _gen-examples
	@$(MAKE) --no-print-directory _gen-modules

lint:
	@if [ "$(LINT_FL_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-files; \
	fi
	@if [ "$(LINT_TF_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-fmt; \
	fi
	@if [ "$(LINT_JL_ENABLE)" = "1" ]; then \
		$(MAKE) --no-print-directory _lint-json; \
	fi

test: _pull-tf
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="/t/examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "################################################################################"; \
		echo "# examples/$$( basename $${DOCKER_PATH} )"; \
		echo "################################################################################"; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform init"; \
		echo "------------------------------------------------------------"; \
		if docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			init \
				-verify-plugins=true \
TFDOCS_VERSION = 0.6.0
				-lock=false \
				-upgrade=true \
				-reconfigure \
				-input=false \
				-get-plugins=true \
				-get=true \
				.; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
		echo "------------------------------------------------------------"; \
		echo "# Terraform validate"; \
		echo "------------------------------------------------------------"; \
		if docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" hashicorp/terraform:$(TF_VERSION) \
			validate \
				-check-variables=true $(ARGS) \
				.; then \
			echo "OK"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
		else \
			echo "Failed"; \
			docker run -it --rm -v "$(CURRENT_DIR):/t" --workdir "$${DOCKER_PATH}" --entrypoint=rm hashicorp/terraform:$(TF_VERSION) -rf .terraform/ || true; \
			exit 1; \
		fi; \
		echo; \
	)


# -------------------------------------------------------------------------------------------------
# Helper Targets
# -------------------------------------------------------------------------------------------------
_gen-main:
	@echo "------------------------------------------------------------"
	@echo "# Main module"
	@echo "------------------------------------------------------------"
	@if docker run --rm \
		-v $(CURRENT_DIR):/data \
		-e DELIM_START='$(DELIM_START)' \
		-e DELIM_CLOSE='$(DELIM_CLOSE)' \
		cytopia/terraform-docs:$(TFDOCS_VERSION) \
		terraform-docs-replace-012 $(TFDOCS_ARGS) md README.md; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi

_gen-examples:
	@$(foreach example,\
		$(TF_EXAMPLES),\
		DOCKER_PATH="examples/$(notdir $(patsubst %/,%,$(example)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TFDOCS_VERSION) \
			terraform-docs-replace-012 $(TFDOCS_ARGS) md $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_gen-modules:
	@$(foreach module,\
		$(TF_MODULES),\
		DOCKER_PATH="modules/$(notdir $(patsubst %/,%,$(module)))"; \
		echo "------------------------------------------------------------"; \
		echo "# $${DOCKER_PATH}"; \
		echo "------------------------------------------------------------"; \
		if docker run --rm \
			-v $(CURRENT_DIR):/data \
			-e DELIM_START='$(DELIM_START)' \
			-e DELIM_CLOSE='$(DELIM_CLOSE)' \
			cytopia/terraform-docs:$(TFDOCS_VERSION) \
			terraform-docs-replace-012 $(TFDOCS_ARGS) md $${DOCKER_PATH}/README.md; then \
			echo "OK"; \
		else \
			echo "Failed"; \
			exit 1; \
		fi; \
	)

_lint-files: _pull-fl
	@# Basic file linting
	@echo "################################################################################"
	@echo "# File-lint"
	@echo "################################################################################"
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-cr --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-crlf --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-single-newline --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-trailing-space --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8 --text --ignore '.git/,.github/,.terraform/' --path .
	@docker run --rm -v $(CURRENT_DIR):/data cytopia/file-lint:$(FL_VERSION) file-utf8-bom --text --ignore '.git/,.github/,.terraform/' --path .

_lint-fmt: _pull-tf
	@# Lint all Terraform files
	@echo "################################################################################"
	@echo "# Terraform fmt"
	@echo "################################################################################"
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tf files"
	@echo "------------------------------------------------------------"
	@if docker run -it --rm -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		fmt -check=true -diff=true -write=false -list=true .; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo
	@echo "------------------------------------------------------------"
	@echo "# *.tfvars files"
	@echo "------------------------------------------------------------"
	@if docker run --rm --entrypoint=/bin/sh -v "$(CURRENT_DIR):/t:ro" --workdir "/t" hashicorp/terraform:$(TF_VERSION) \
		-c "find . -name '*.tfvars' -type f -print0 | xargs -0 -n1 terraform fmt -check=true -write=false -diff=true -list=true"; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

_lint-json: _pull-jl
	@# Lint all JSON files
	@echo "################################################################################"
	@echo "# Jsonlint"
	@echo "################################################################################"
	@if docker run --rm -v "$(CURRENT_DIR):/data:ro" cytopia/jsonlint:$(JL_VERSION) \
		-t '  ' -i '*.terraform/*' '*.json'; then \
		echo "OK"; \
	else \
		echo "Failed"; \
		exit 1; \
	fi;
	@echo

_pull-tf:
	docker pull hashicorp/terraform:$(TF_VERSION)

_pull-tfdocs:
	docker pull cytopia/terraform-docs:$(TFDOCS_VERSION)

_pull-fl:
	docker pull cytopia/file-lint:$(FL_VERSION)

_update-tf-docs:
	docker pull cytopia/terraform-docs:$(TF_DOCS_VERSION)

## Lint and generate README.md
all: lint readme

## Generate README.md terraform variable and output maps
readme:
	@grep -q "$(DELIM_START)" README.md; \
	if [ $$? -ne 0 ]; then \
		echo >> README.md; \
		echo "$(DELIM_START)" >> README.md; \
		echo "$(DELIM_CLOSE)" >> README.md; \
	fi; \
	$(MAKE) gen

## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || terraform $@

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	terraform $@
