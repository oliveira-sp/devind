include examples/examples.mk
include test/test.mk

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
	$(QUIET)echo "Removing generated files.."
	$(QUIET)rm -rf .devind

# Automatic help documentation ================================================
.PHONY: help
help: ## Display this help
	$(QUIET)echo "Usage: ./devind [options] [target]"
	$(QUIET)echo "Devind Targets:"
	$(QUIET)grep -hE '^[a-zA-Z0-9_.%/-]+:.*## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN { FS = ":.*## " } { printf "\033[34m  %-30s\033[0m %s\n", $$1, $$2 }'
