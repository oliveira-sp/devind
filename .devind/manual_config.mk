# Default devtaget selection
DEVIND_DEFAULT_DEVTARGET ?= dev-local
DEVIND_DEVTARGET = $(DEVIND_DEFAULT_DEVTARGET)

# Global variables
DOCKER_IMAGE:= example/devind:1.0
CMD_EXEC:=make -f $(DEVIND_MAKEFILE_ENTRY)

# Profiles recipe definitions
profile-docker:
	$(eval DOCKER_CMD:= docker run)

profile-docker-interactive:
	$(eval DOCKER_OPT+=-it)

profile-docker-remove:
	$(eval DOCKER_OPT+=--rm)

profile-docker-detach:
	$(eval DOCKER_OPT+=-d)

profile-docker-bind-workspace:
	$(eval DOCKER_OPT+=-v .:/home/dev)
	$(eval DOCKER_OPT+=-w /home/dev)

profile-dummy:
	$(eval DUMMY_VAR:= $(FOO))

# Devtargets recipe definitions
dev-local:
	$(eval DEVIND_DEVTARGET:=$@)
	$(eval CMD_PREFIX:=$(CMD_EXEC))

dev-docker: profile-docker profile-docker-remove profile-docker-interactive profile-docker-bind-workspace
	$(eval DEVIND_DEVTARGET:=$@)
	$(eval DOCKER_NAME:= my-docker-build-container)
	$(eval DOCKER_OPT+= --name $(DOCKER_NAME))
	$(eval CMD_PREFIX:=$(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE) $(CMD_EXEC))

dev-ssh:
	$(eval DEVIND_DEVTARGET:=$@)
	$(eval SSH_USER:=root)
	$(eval SSH_HOST:=localhost)
	$(eval SSH_CMD:=ssh $(SSH_USER):$(SSH_HOST))
	$(eval CMD_EXEC:=make -f $(DEVIND_MAKEFILE_ENTRY))
	$(eval CMD_PREFIX:=$(SSH_CMD) $(CMD_EXEC))

# Makefile targets mapping
a: dev-docker
b: dev-local profile-dummy
#c has no devtarget defined, will use DEVIND_DEFAULT_DEVTARGET
