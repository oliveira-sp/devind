include examples/examples.mk

ifeq ($(V),1)
QUIET := 
else
QUIET := @
endif

DEVIND_SCRIPT:= src/devind

.PHONY: dist
dist: ## Not yet implemented

.PHONY: clean
clean: ## Clean generated files and folders
	$(QUIET)echo "[CLEAN] Removing generated files.."
	$(QUIET)rm -rf .devind

.PHONY: help
help: ## Display this help
	$(QUIET)echo Usage: make [options] [target]
	$(QUIET)echo Targets:
	$(QUIET)grep --no-filename -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[34m  %-20s\033[0m %s\n", $$1, $$2}'
