DERIVED_DATA_PATH=.derivedData
PLATFORM='iOS Simulator,name=iPhone 12,OS=latest'

export TUIST_STATS_OPT_OUT := true

.PHONY: setup-brew
setup-brew:
	brew install -q \
		swiftformat \
		swiftlint \
		xcbeautify

.PHONY: setup-brew-ci
setup-brew-ci:
	brew install -q xcbeautify
	swiftlint --version
	swiftformat --version

.PHONY: setup-tuist
setup-tuist:
ifeq ($(shell which tuist),)
	curl -Ls https://install.tuist.io | bash
else
	@echo "Tuist is already installed, checking the version now..."
	tuist version
endif

.PHONY: setup
setup: setup-brew setup-tuist

.PHONY: setup-ci
setup-ci: setup-brew-ci setup-tuist

.PHONY: edit
edit:
	tuist edit

.PHONY: generate
generate:
	tuist generate --no-open

.PHONY: open
open:
	tuist generate

.PHONY: lint
lint:
	swiftformat --cache ignore --lint .
	swiftlint --strict

.PHONY: build
build:
	set -o pipefail && xcodebuild \
		-workspace Netbob.xcworkspace \
		-scheme Netbob \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination platform=$(PLATFORM) \
		build-for-testing | xcbeautify

.PHONY: test
test:
	set -o pipefail && xcodebuild \
		-workspace Netbob.xcworkspace \
		-scheme Netbob \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination platform=$(PLATFORM) \
		test-without-building | xcbeautify

.PHONY: clean
clean:
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf *.xcodeproj
	rm -rf *.xcworkspace
	tuist clean
