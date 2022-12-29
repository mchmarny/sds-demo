VERSION   ?=$(shell cat .version)

all: help

version: ## Prints the current version
	@echo $(VERSION)
.PHONY: version

tidy: ## Updates the go modules and vendors all dependancies 
	go mod tidy
	go mod vendor
.PHONY: tidy

upgrade: ## Upgrades all dependancies 
	go get -d -u ./...
	go mod tidy
	go mod vendor
.PHONY: upgrade

test: tidy ## Runs unit tests
	go test -short -count=1 -race -covermode=atomic -coverprofile=cover.out ./...
.PHONY: test

run: ## Runs uncompiled app 
	go run main.go
.PHONY: run

tag: ## Creates release tag 
	git tag -s -m "demo version bump to $(VERSION)" $(VERSION)
	git push origin $(VERSION)
.PHONY: tag

tagless: ## Delete the current release tag 
	git tag -d $(VERSION)
	git push --delete origin $(VERSION)
.PHONY: tagless

clean: ## Cleans bin and temp directories
	go clean
	rm -fr ./vendor
	rm -fr ./bin
.PHONY: clean

help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
