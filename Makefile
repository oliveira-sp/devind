include examples/examples.mk
include test/test.mk

ifeq ($(V),1)
QUIET := 
else
QUIET := @
endif

VERSION = $(shell git describe --tags --always --dirty)

DEVIND_SCRIPT:= src/devind
DEVIND_PARSER:= src/devind_yaml_parser.awk

BUILD_FOLDER:= .build

AWK_MINIMIZER_SCRIPT:= tools/awk_minimizer.sh
PARSER_INSERT_SCRIPT:= tools/insert_content.sh
MINIMIZED_PARSER:= $(BUILD_FOLDER)/min_yaml_parser.awk
MINIMIZED_PARSER_ESCAPED := $(BUILD_FOLDER)/min_escaped_yaml_parser.awk
DEVIND_OUTPUT:= $(BUILD_FOLDER)/devind

$(BUILD_FOLDER):
	$(QUIET)echo "Creating $@ folder"
	$(QUIET)mkdir -p $@

$(MINIMIZED_PARSER): $(DEVIND_PARSER) | $(BUILD_FOLDER)
	$(QUIET)$(AWK_MINIMIZER_SCRIPT) $< $@

$(MINIMIZED_PARSER_ESCAPED): $(MINIMIZED_PARSER) | $(BUILD_FOLDER)
	$(QUIET)sed \
		-e 's/[$$]/$$$$/g' \
		-e 's/&/\\&/g' \
		"$(MINIMIZED_PARSER)" > $@

$(DEVIND_OUTPUT): $(DEVIND_SCRIPT) $(MINIMIZED_PARSER_ESCAPED) | $(BUILD_FOLDER)
	$(QUIET)echo "Building: $@"
	$(QUIET)cp $< $@
	$(QUIET)echo "  Injecting version in $@ ..."
	$(QUIET)$(PARSER_INSERT_SCRIPT) '__VERSION__' $(VERSION) $@
	$(QUIET)echo "  Embedding minimized yaml parser in $@ ..."
	$(QUIET)$(PARSER_INSERT_SCRIPT) '__YAML_MINIMIZED_PARSER_CODE__' -f $(MINIMIZED_PARSER_ESCAPED) $@
	$(QUIET)chmod +x $@

.PHONY: build
build: $(DEVIND_OUTPUT) ## Build the devind script and place it in the build folder
	$(QUIET)echo "\nDevind script built successfully here: $<\n"

.PHONY: dist
dist: ## Not yet implemented

.PHONY: clean
clean: ## Clean generated files and folders
	$(QUIET)echo "Removing generated files"
	$(QUIET)rm -rf $(BUILD_FOLDER)

# Automatic help documentation ================================================
.PHONY: help
help: ## Display this help
	$(QUIET)echo "Usage: ./devind [options] [target]"
	$(QUIET)echo "Devind Targets:"
	$(QUIET)grep -hE '^[a-zA-Z0-9_.%/-]+:.*## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN { FS = ":.*## " } { printf "\033[34m  %-30s\033[0m %s\n", $$1, $$2 }'
