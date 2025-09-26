.PHONY: default
default: help

.PHONY: help
##@ Pattern tasks

# No need to add a comment here as help is described in common/
#help:
#	@make -f /Makefile MAKEFILE_LIST="Makefile common/Makefile" help
#
#%:
#	make -f common/Makefile $*

.PHONY: install
install: ## Run playbook
	ansible-playbook site.yaml

.PHONY: destroy
destroy: ## Post-install tasks
