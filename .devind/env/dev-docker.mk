DEVIND_DEVTARGET:=dev_docker

DOCKER_IMAGE:= example/devind:1.0
DOCKER_CMD := docker run
DOCKER_NAME := my-docker-build-container
DOCKER_OPT += --name $(DOCKER_NAME)
DOCKER_OPT += -v .:/home/dev
DOCKER_OPT += -w /home/dev
DOCKER_OPT += --rm

CMD_PREFIX := $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE) $(CMD_EXEC)