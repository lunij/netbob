DERIVED_DATA_PATH=.derivedData
PLATFORM='iOS Simulator,name=iPhone 12,OS=latest'

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
