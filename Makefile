CAKEPHP_SOURCE_DIR=../cakephp
CHRONOS_SOURCE_DIR=../chronos
ELASTIC_SOURCE_DIR=../elastic-search
QUEUE_SOURCE_DIR=../queue
BUILD_DIR=./build/api
DEPLOY_DIR=./website
PHP8=php
PHP7=php7
COMPOSER=$(PWD)/composer.phar

.PHONY: clean help
.PHONY: build-all
.PHONY: build-active-and-missing
.ALL: help

# Versions that can be built.
CAKEPHP_VERSIONS = 3.8 3.9 3.10 4.0 4.1 4.2 4.3 4.next

CHRONOS_VERSIONS = 1.x 2.x

ELASTIC_VERSIONS = 2.x 3.x

QUEUE_VERSIONS = 0.x

FOB_VERSIONS = 1.0.0

help:
	@echo "FriendsOfBabba/Core Documentation generator"
	@echo "-----------------------------------"
	@echo ""
	@echo "Tasks:"
	@echo ""
	@echo " clean - Clean the build output directory"
	@echo ""
	@echo " build-x.y - Build the x.y documentation. The versions that can be"
	@echo "             built are:"
	@echo "             $(VERSIONS)"
	@echo " build-all     - Build all versions of the documentation"
	@echo ""
	@echo "Variables:"
	@echo " CAKEPHP-SOURCE_DIR - Define where your cakephp clone is. This clone will have its"
	@echo "                      currently checked out branch manipulated. Default: $(CAKEPHP_SOURCE_DIR)"
	@echo " BUILD_DIR  - The directory where the output should go. Default: $(BUILD_DIR)"
	@echo " DEPLOY_DIR - The directory files shold be copied to in `deploy` Default: $(DEPLOY_DIR)"

clean:
	rm -rf $(DEPLOY_DIR)
	rm -rf $(BUILD_DIR)


# Make the deployment directory
$(DEPLOY_DIR):
	mkdir -p $(DEPLOY_DIR)

deploy: $(DEPLOY_DIR)
	for release in $$(ls $(BUILD_DIR)); do \
		rm -rf $(DEPLOY_DIR)/$$release; \
		mkdir -p $(DEPLOY_DIR)/$$release; \
		mv $(BUILD_DIR)/$$release $(DEPLOY_DIR)/; \
	done


composer.phar:
	curl -sS https://getcomposer.org/installer | php

install: composer.phar
	$(PHP8) $(COMPOSER) install

define fob
build-fob-$(VERSION): install
	cd $(FOB_SOURCE_DIR) && git checkout -f $(TAG)
	cd $(FOB_SOURCE_DIR) && $(PHP7) $(COMPOSER) update
	mkdir -p $(BUILD_DIR)/fob/$(VERSION)
	cp -r static/assets/* $(BUILD_DIR)/fob/$(VERSION)

	$(PHP8) bin/apitool.php generate --config fob --version $(VERSION) \
		$(FOB_SOURCE_DIR) $(BUILD_DIR)/fob/$(VERSION)
endef

# Build all the versions in a loop.
# build-all: $(foreach version, $(CAKEPHP_VERSIONS), build-cakephp-$(version)) $(foreach version, $(CHRONOS_VERSIONS), build-chronos-$(version)) $(foreach version, $(ELASTIC_VERSIONS), build-elastic-$(version)) $(foreach version, $(QUEUE_VERSIONS), build-queue-$(version)) $(foreach version, $(FOB_VERSIONS), build-fob-$(version))
build-all: $(foreach version, $(FOB_VERSIONS), build-fob-$(version))

# Generate build targets for fob
TAG:=origin/main
VERSION:=1.0.0
$(eval $(fob))