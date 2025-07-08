include examples/examples.mk
include test/test.mk

ifeq ($(V),1)
QUIET := 
else
QUIET := @
endif

DEVIND_SCRIPT:= src/devind
DEVIND_PARSER:= src/devind_yaml_parser.awk

BUILD_FOLDER:= .build

AWK_MINIMIZER_SCRIPT:= tools/awk_minimizer.sh
MINIMIZED_PARSER:= $(BUILD_FOLDER)/minimized.awk
DEVIND_OUTPUT:= $(BUILD_FOLDER)/devind

$(BUILD_FOLDER):
	$(QUIET)echo "Creating $@ folder.."
	$(QUIET)mkdir -p $@

$(MINIMIZED_PARSER): $(DEVIND_PARSER) | $(BUILD_FOLDER)
	$(QUIET)echo "Minimizing awk parser.."
	$(QUIET)$(AWK_MINIMIZER_SCRIPT) $< $@

$(DEVIND_OUTPUT): $(DEVIND_SCRIPT) $(MINIMIZED_PARSER) | $(BUILD_FOLDER)
	$(QUIET)echo "Building devind.."
	$(QUIET)cp $< $@
	$(QUIET)chmod +x $@

.PHONY: build
build: $(DEVIND_OUTPUT) ## Build the devind script and place it in the build folder
	$(QUIET)echo "Devind script built successfully here: $<"

.PHONY: dist
dist: ## Not yet implemented

.PHONY: clean
clean: ## Clean generated files and folders
	$(QUIET)echo "Removing generated files.."
	$(QUIET)rm -rf $(BUILD_FOLDER)

# Automatic help documentation ================================================
.PHONY: help
help: ## Display this help
	$(QUIET)echo "Usage: ./devind [options] [target]"
	$(QUIET)echo "Devind Targets:"
	$(QUIET)grep -hE '^[a-zA-Z0-9_.%/-]+:.*## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN { FS = ":.*## " } { printf "\033[34m  %-30s\033[0m %s\n", $$1, $$2 }'
