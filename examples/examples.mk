DEVIND := $(realpath src/devind)

.PHONY: run-example-%
run-example-%: ## Run example by folder name
	$(QUIET)./$(DEVIND_SCRIPT) \
		DEVIND_MAKEFILE_ENTRY=examples/$*/Makefile \
		DEVIND_YAML_FILE=examples/$*/devind.yaml \
		YAML_TOOL=src/devind_yaml_parser.awk \
		$(GOALS)
