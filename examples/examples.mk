EXAMPLES := $(notdir $(shell find examples -mindepth 1 -maxdepth 1 -type d))

.PHONY: run-example-%
run-example-%: ## Run example by folder name
	$(QUIET)./$(DEVIND_SCRIPT) \
		DEVIND_MAKEFILE_ENTRY=examples/$*/Makefile \
		DEVIND_YAML_FILE=examples/$*/devind.yaml \
		YAML_TOOL=src/devind_yaml_parser.awk $(GOALS)

.PHONY: list-examples
list-examples: ## List available examples and display usage
	$(QUIET)echo "Usage: make run-example-<name> GOALS=your_goal"
	$(QUIET)echo
	$(QUIET)echo "Available examples:"
	$(QUIET)for d in $(EXAMPLES); do echo " - $$d"; done
	$(QUIET)echo
	$(QUIET)echo "Example:"
	$(QUIET)echo "  make run-example-$(firstword $(EXAMPLES)) GOALS=clean"
