DERIVED_DATA_PATH=.derivedData
PLATFORM='iOS Simulator,name=iPhone 12,OS=latest'

export TUIST_STATS_OPT_OUT := true

setup:
	curl -Ls https://install.tuist.io | bash
	tuist up

edit:
	tuist edit --permanent
	open Manifests.xcodeproj

generate:
	tuist generate

open: generate
open:
	open Netbob.xcworkspace

lint:
	swiftformat --cache ignore --lint .
	swiftlint --strict

build:
	set -o pipefail && xcodebuild \
		-workspace Netbob.xcworkspace \
		-scheme Netbob \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination platform=$(PLATFORM) \
		build-for-testing | xcbeautify

test:
	set -o pipefail && xcodebuild \
		-workspace Netbob.xcworkspace \
		-scheme Netbob \
		-configuration Debug \
		-derivedDataPath $(DERIVED_DATA_PATH) \
		-destination platform=$(PLATFORM) \
		test-without-building | xcbeautify

clean:
	rm -rf $(DERIVED_DATA_PATH)
	rm -rf *.xcodeproj
	rm -rf *.xcworkspace
	tuist clean

.PHONY: build clean edit generate lint open setup test
