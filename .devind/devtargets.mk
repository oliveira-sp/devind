# Internal Makefile: Handles per-goal execution

# Goal-to-devtarget mapping
define devtarget_for_goal
  $(if $(filter $(1),a c e g),dev-local,$(if $(filter $(1),b d f),dev-docker,dev-local))
endef

# Define CMD_EXEC for sub-make invocation
CMD_EXEC := make -f $(DEVIND_MAKEFILE_ENTRY)

