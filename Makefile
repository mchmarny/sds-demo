VERSION   ?=$(shell cat app/.version)

all: help

.PHONY: version
version: ## Prints the current demo app version
	@echo $(VERSION)

.PHONY: infra
infra: ## Applies Terraform
	terraform -chdir=./deployment apply -auto-approve

.PHONY: push
push: ## Pushes all outstanding changes to the remote repository
	git add --all
	git commit -m 'demo'
	git push --all

.PHONY: tag
tag: ## Creates release tag
	git tag -s -m "demo version bump to $(VERSION)" $(VERSION)
	git push origin $(VERSION)

.PHONY: tagless
tagless: ## Delete the current release tag 
	git tag -d $(VERSION)
	git push --delete origin $(VERSION)

.PHONY: help
help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

