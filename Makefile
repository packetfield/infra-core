# SHELL:=/bin/bash

.DEFAULT_GOAL:=help

#always default ENV to 'unknown' if unset
ENV ?= unknown

export ROOTDIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

export VENDOR_DIR         := $(ROOTDIR)/vendor
export VIRTUAL_ENV        := $(VENDOR_DIR)/python

################### PATH updates
# add the locally tracked git scripts to $PATH
export PATH := $(ROOTDIR)/bin:$(PATH)
#
# add vendored stuff like terraform/kubectl to $PATH
export PATH := $(VENDOR_DIR)/bin:$(VIRTUAL_ENV)/bin:$(PATH)
#
# Add virtualenv to path
export PATH := $(VIRTUAL_ENV)/bin:$(PATH)
########################################

export GCE_PROJECT        := packetfield

# stuff from keybase
export KEYBASE_TEAM_DIR   := /keybase/team/$(GCE_PROJECT)

# secrets inside the teams keybase
export GOOGLE_APPLICATION_CREDENTIALS  := $(KEYBASE_TEAM_DIR)/packetfield-d853f51b2b3c.json
export ANSIBLE_VAULT_PASSWORD_FILE     := $(KEYBASE_TEAM_DIR)/ansible_vault.txt

# for ansible and terraform credentials
# export GCE_EMAIL          := infrastructure@${GCE_PROJECT}.iam.gserviceaccount.com
# export GCE_INI_PATH       := $(ROOTDIR)/ansible/inventory/gce.ini
# export GOOGLE_CREDENTIALS := $(shell cat ${GCE_PEM_FILE_PATH})
# export GOOGLE_APPLICATION_CREDENTIALS := $(GCE_PEM_FILE_PATH)
export BUCKET             := $(GCE_PROJECT)-terraform-state
export REMOTE_USERNAME    ?= $(USER)


# gce.py will filter only for hosts with a tag that matches this
export INVENTORY_TAG_FILTER := $(ENV)


## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[1m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

## Cleanup logs/python/virtualenv/binaries/terraform local state
# Usage:
#  make clean
clean: clean-virtualenv clean-terraform clean-vendor

#/ clean just the vendored downloaded binaries
clean-vendor:
	rm -rf "$(VENDOR_DIR)/bin/"*
	rm -rf "$(VENDOR_DIR)/tmp/"*

#/ clean just the virtualenv
clean-virtualenv:
	rm -rf "$(VIRTUAL_ENV)/"*

#/ clean .terraform and old state
clean-terraform:
	@find "$(ROOTDIR)" -type d -name .terraform -exec rm -rv {} +
	@find "$(ROOTDIR)" -type f -name terraform.tfstate -exec rm -v {} +
	@find "$(ROOTDIR)" -type f -name terraform.tfstate.backup -exec rm -v {} +

#/ cleans up a component specifically
#    NOTE: this is an especially important part of the flow when using terraform.
#          Unfortunately, because it stores temp state etc in the same relative path at runtime
#            if you switch environments from say staging > master it may get confused because
#            of your previous run's state files and tmp stuff inside the same directory
#          TL;DR, rm -rf local storage between runs.., use the cloud for state
component-clean:
	@find "$(ROOTDIR)/terraform/$(COMPONENT)" -type f -name terraform.tfstate -exec rm -v {} +
	@find "$(ROOTDIR)/terraform/$(COMPONENT)" -type f -name terraform.tfstate.backup -exec rm -v {} +

## Install all dependencies
# Usage:
#  make deps
deps: deps_python deps_bin

deps_ansible:
	ansible-galaxy install --role-file="$(ROOTDIR)/galaxy.yml" --roles-path="$(ROOTDIR)/roles_vendor" --force

deps_bin:
	"$(ROOTDIR)/bin/download_binary" terraform

#/ activates virenv and installs deps
deps_python:
	cd "$(ROOTDIR)"
	@if [ ! -d $(VIRTUAL_ENV)/bin ] ; \
	then \
		virtualenv --python=python2.7 "$(VIRTUAL_ENV)" ; \
	fi
	. $(VIRTUAL_ENV)/bin/activate && \
	$(VIRTUAL_ENV)/bin/pip2.7 install -r $(ROOTDIR)/requirements.txt  -q

## terraform init
# Usage:
#  make ENV=develop COMPONENT=something init
init: component-clean
	cd "$(ROOTDIR)/terraform/$(COMPONENT)" && \
	terraform init \
		-backend-config="project=$(GCE_PROJECT)" \
		-backend-config="bucket=$(BUCKET)" \
		-backend-config="path=$(ENV)/$(COMPONENT)/terraform.tfstate" \
		-get=true -get-plugins=true -force-copy=true -input=false

## terraform plan
# Usage: (note: includes the init and a clean)
#  make ENV=develop COMPONENT=something plan
plan: init
	cd "$(ROOTDIR)/terraform/$(COMPONENT)" && \
	terraform plan \
		-var-file=config-$(ENV).tfvars \
		-var env=$(ENV) \
		-var component=$(COMPONENT) \
		-var project=$(GCE_PROJECT)

## terraform apply
# Usage:
#  make ENV=develop COMPONENT=kafka apply
apply: init
	cd "$(ROOTDIR)/terraform/$(COMPONENT)" && \
	terraform apply \
		-var-file=config-$(ENV).tfvars \
		-var env=$(ENV) \
		-var component=$(COMPONENT) \
		-var project=$(GCE_PROJECT) \
		-input=false -auto-approve \
		$(ARGS)

# ## destroy infrastructure with terraform
# # Usage:
# #  make ENV=develop COMPONENT=kafka destroy-apply
# destroy-apply: component-clean
# 	cd "$(ROOTDIR)/terraform/$(COMPONENT)" ; \
# 	terraform init \
# 		-backend-config="project=$(GCE_PROJECT)" \
# 		-backend-config="bucket=$(BUCKET)" \
# 		-backend-config="path=$(ENV)/$(COMPONENT)/terraform.tfstate" \
# 		-get=true -get-plugins=true -force-copy=true -input=false
# 	cd "$(ROOTDIR)/terraform/$(COMPONENT)" ; \
# 	terraform destroy -force \
# 		-var-file=config-$(ENV).tfvars \
# 		-var env=$(ENV) \
# 		-var component=$(COMPONENT) \
# 		-var project=$(GCE_PROJECT)


# ## preview what terraform will destroy
# # Usage:
# #  make ENV=develop COMPONENT=kafka destroy-plan
# destroy-plan: component-clean
# 	cd "$(ROOTDIR)/terraform/$(COMPONENT)" ; \
# 	terraform init \
# 		-backend-config="project=$(GCE_PROJECT)" \
# 		-backend-config="bucket=$(BUCKET)" \
# 		-backend-config="path=$(ENV)/$(COMPONENT)/terraform.tfstate" \
# 		-get=true -get-plugins=true -force-copy=true -input=false
# 	cd "$(ROOTDIR)/terraform/$(COMPONENT)" ; \
# 	terraform plan -destroy \
# 		-var-file=config-$(ENV).tfvars \
# 		-var env=$(ENV) \
# 		-var component=$(COMPONENT) \
# 		-var project=$(GCE_PROJECT)

## see if you can communicate with hosts
# Usage:
#  make ENV=develop COMPONENT=zookeeper ping
ping:
	cd "$(ROOTDIR)/ansible" && \
	"$(VIRTUAL_ENV)/bin/ansible" \
		-u $(REMOTE_USERNAME) \
		-i inventory/gce.py \
		"tag_$(COMPONENT)" \
		-m ping

## configure hosts via ansible, you can pass extra args with the $ARGS envvar
# Usage:
#  make ENV=develop COMPONENT=elastic config
#   or for more verbosity (EG):
#  make ENV=develop COMPONENT=elastic ARGS="-vv" config
config:
	cd "$(ROOTDIR)/ansible" && \
	"$(VIRTUAL_ENV)/bin/ansible-playbook" \
		-u $(REMOTE_USERNAME) \
		-i inventory/gce.py \
		--extra-vars "@$(ROOTDIR)/ansible/vars/$(ENV).yml" \
		--extra-vars "@$(ROOTDIR)/ansible/vars/$(ENV)-secrets.yml" \
		--extra-vars "component=$(COMPONENT)" \
		playbooks/$(COMPONENT).yml $(ARGS)


# ## run the ansible "setup" module against instances (to see available variables)
# # Usage:
# #  make ENV=develop COMPONENT=somehost setup
# setup:
# 	"$(VIRTUAL_ENV)/bin/ansible" \
# 		-u $(REMOTE_USERNAME) \
# 		-i inventory/gce.py \
# 		"tag_$(COMPONENT)" \
# 		--extra-vars "@$(ROOTDIR)/vars/$(ENV).yml" \
# 		--extra-vars "@$(ROOTDIR)/vars/$(ENV)-secrets.yml" \
# 		--extra-vars "component=$(COMPONENT)" \
# 		-m setup

## get ssh access to machine(s) quickly via gcloud and tags of instances
# Usage:
#  make ENV=develop COMPONENT=zookeeper ssh
ssh:
	@$(ROOTDIR)/bin/make-ssh "$(COMPONENT)" "$(ENV)"


# ## quickly run a command via ansible
# # Usage:
# #  make ENV=develop COMPONENT=somehost run CMD="df -h"
# run:
# 	"$(VIRTUAL_ENV)/bin/ansible" \
# 		-u $(REMOTE_USERNAME) \
# 		-i inventory/gce.py \
# 		"tag_$(COMPONENT)" \
# 		--extra-vars "@$(ROOTDIR)/vars/$(ENV).yml" \
# 		--extra-vars "@$(ROOTDIR)/vars/$(ENV)-secrets.yml" \
# 		--extra-vars "env=$(ENV)" \
# 		--extra-vars "component=$(COMPONENT)" \
# 		-m shell \
# 		-a "$(CMD)"

