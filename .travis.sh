#! /usr/bin/env sh

set -eo pipefail
# set -euxo pipefail

echo $TRAVIS_COMMIT_MESSAGE
echo "RFCI_TASK = $RFCI_TASK"
readonly RFWorkspace="RFAlpha.xcworkspace"
readonly RFSTAGE="$1"
echo "RFSTAGE = $RFSTAGE"

# Run test
# $1 scheme
# $2 destination
XC_Test() {
    xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "$1" -destination "$2" ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
}

# Run macOS test
XC_TestMac() {
    xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "Test-macOS" GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
}

# Run watchOS test
XC_TestWatch() {
    xcodebuild build -workspace "$RFWorkspace" -scheme Target-watchOS ONLY_ACTIVE_ARCH=NO | xcpretty
}

STAGE_MAIN() {
    if [ "$RFCI_TASK" = "POD_LINT" ]; then
        if [[ "$TRAVIS_COMMIT_MESSAGE" = *"[skip lint]"* ]]; then
            echo "Skip pod lint"
        else
            echo "TRAVIS_BRANCH = $TRAVIS_BRANCH"
            gem install cocoapods --no-rdoc --no-ri --no-document --quiet
            # Always allow warnings as alpha.
            pod lib lint --allow-warnings
        fi

    elif [ "$RFCI_TASK" = "Xcode9" ]; then
        pod install
    else
        echo "Unexpected CI task: $RFCI_TASK"
    fi
}

STAGE_SUCCESS() {
    if [ "$RFCI_TASK" = "Xcode9" ]; then
        curl -s https://codecov.io/bash | bash -s
    fi
}

STAGE_FAILURE() {
    if [[ "$RFCI_TASK" == Xcode* ]]; then
        cat -n ~/Library/Logs/DiagnosticReports/xctest*.crash
    fi
}

"STAGE_$RFSTAGE"
