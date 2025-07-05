# Unit-testing related targets ================================================
TEST_IMAGE_NAME := devind-test:latest
TEST_IMAGE_STAMP := test/.devind-test.built
TEST_DOCKERFILE := test/Dockerfile
TEST_CONTEXT := test
TEST_DOCKER_OPTIONS := --rm -v "${PWD}:/code"

ifdef CI
TEST_DOCKER_OPTIONS += -i
else
TEST_DOCKER_OPTIONS += -it
endif

.PHONY: test
test: build-test-image ## Execute DevinD unit-tests
	docker run $(TEST_DOCKER_OPTIONS) $(TEST_IMAGE_NAME) test --report-formatter junit

$(TEST_IMAGE_STAMP): $(TEST_DOCKERFILE)
	@echo "[+] Building $(TEST_IMAGE_NAME)..."
	@docker build -t $(TEST_IMAGE_NAME) -f $(TEST_DOCKERFILE) $(TEST_CONTEXT)
	@touch $(TEST_IMAGE_STAMP)

.PHONY: build-test-image
build-test-image: $(TEST_IMAGE_STAMP) ## Build image only if stamp is missing or Dockerfile changed

.PHONY: clean-test-image
clean-test-image: ## Clean test image
	@echo "[~] Removing $(TEST_IMAGE_NAME) image and build stamp..."
	@docker rmi $(TEST_IMAGE_NAME) || true
	@rm -f $(TEST_IMAGE_STAMP)
