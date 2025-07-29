include examples/examples.mk
include test/test.mk

ifeq ($(V),1)
QUIET := 
else
QUIET := @
endif

SED_INPLACE := sed -i
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
  SED_INPLACE := sed -i ''
endif

VERSION = $(shell git describe --tags --always --dirty)

DEVIND_SCRIPT:= src/devind
DEVIND_PARSER:= src/devind_yaml_parser.awk

BUILD_FOLDER:= .build

AWK_MINIMIZER_SCRIPT:= tools/awk_minimizer.sh
MINIMIZED_PARSER:= $(BUILD_FOLDER)/min_yaml_parser.awk
MINIMIZED_PARSER_ESCAPED := $(BUILD_FOLDER)/min_escaped_yaml_parser.awk
DEVIND_OUTPUT:= $(BUILD_FOLDER)/devind

$(BUILD_FOLDER):
	$(QUIET)echo "Creating $@ folder.."
	$(QUIET)mkdir -p $@

$(MINIMIZED_PARSER): $(DEVIND_PARSER) | $(BUILD_FOLDER)
	$(QUIET)echo "Minimizing awk parser.."
	$(QUIET)$(AWK_MINIMIZER_SCRIPT) $< $@

$(MINIMIZED_PARSER_ESCAPED): $(MINIMIZED_PARSER) | $(BUILD_FOLDER)
	$(QUIET)echo "Escaping awk parser for embedding.."
	$(QUIET)sed \
		-e 's/[$$]/$$$$/g' \
		-e 's/&/\\&/g' \
		"$(MINIMIZED_PARSER)" > $@

$(DEVIND_OUTPUT): $(DEVIND_SCRIPT) $(MINIMIZED_PARSER_ESCAPED) | $(BUILD_FOLDER)
	$(QUIET)echo "Building $@.."
	$(QUIET)cp $< $@
	$(QUIET)echo "Injecting version in $@ ..."
	$(QUIET)$(SED_INPLACE) 's/__VERSION__/$(VERSION)/' $@
	$(QUIET)chmod +x $@

.PHONY: build
build: $(DEVIND_OUTPUT) ## Build the devind script and place it in the build folder
	$(QUIET)echo "Devind script built successfully here: $<"

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
