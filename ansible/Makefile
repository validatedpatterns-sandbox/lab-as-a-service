.PHONY: default
default: help

.PHONY: help
##@ Pattern tasks

# No need to add a comment here as help is described in common/
#help:
#	@make -f /Makefile help
##
#%:
#	make -f Makefile $*
#
.PHONY: install
install: ## Run playbook
	ansible-playbook site.yml

.PHONY: idm-setup
idm-setup: ## Create ec2 instance and setup AAP on it
	ansible-playbook -i hosts playbooks/site.yml

.PHONY: idm-destroy
idm-destroy: ## Destroy AAP ec2 instance
	ansible-playbook -i hosts playbooks/destroy.yml

.PHONY: idm-users
idm-users: ## Create ec2 instance and setup AAP on it
	ansible-playbook -i hosts playbooks/idm_users.yml
