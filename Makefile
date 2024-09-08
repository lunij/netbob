DERIVED_DATA_PATH=.derivedData
PLATFORM='iOS Simulator,name=iPhone 15,OS=17.5'
SCHEME_PACKAGE = "Netbob"

XCODEBUILD_OPTIONS = \
	-configuration Debug \
	-derivedDataPath $(DERIVED_DATA_PATH) \
	-destination platform=$(PLATFORM) \
	-scheme $(SCHEME_PACKAGE) \
	-workspace .

XCODEBUILD_TEST_OPTIONS = -resultBundlePath $(DERIVED_DATA_PATH)/$(SCHEME_PACKAGE)

export TUIST_STATS_OPT_OUT := true

.PHONY: setup-mise
setup-mise:
	curl https://mise.run | sh
	mise install

.PHONY: setup
setup: setup-mise

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

.PHONY: format
format:
	swiftformat .
	swiftlint --quiet --strict --no-cache --fix

.PHONY: build
build:
	set -o pipefail && xcodebuild $(XCODEBUILD_OPTIONS) build-for-testing | xcbeautify

.PHONY: test
test:
	set -o pipefail && xcodebuild $(XCODEBUILD_OPTIONS) $(XCODEBUILD_TEST_OPTIONS) test-without-building | xcbeautify

.PHONY: clean
clean:
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf *.xcodeproj
	rm -rf *.xcworkspace
	tuist clean
