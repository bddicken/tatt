#!/bin/bash

# Initialize our own option and settings variables
TEST_DIR="./tests"
EXE_DIR="./"
SEPARATOR="---------------------"
CLEAR_ACTUAL_FILES="NO"
UPDATE_EXPECTED_FILES="NO"
IGNORE_ORDER="NO"
IGNORE_WHITESPACE="NO"
EXPECTED=expected.txt
ACTUAL=actual.txt

#
# A function that prints out the help message
#
show_help() {
    echo ""
    echo "usage: ./tatt.sh [args]"
    echo ""
    echo "args:"
    echo "  -h  Show this help message."
    echo "  -t  Specify the directory containing tests directories to run."
    echo "      Default: ${TEST_DIR}"
    echo "  -s  Specify the directory to find the program/script that the tests execute."
    echo "      Default: ${EXE_DIR}"
    echo "  -c  Run tatt in cleanup mode. In cleanup mode, tatt removes all extraneous ${EXPECTED} files."
    echo "      Cleanup mode does not do any test execution"
    echo "  -u  Run tatt in update mode. In update mode, tatt updates all ${EXPECTED} files with the contents"
    echo "      Of the corresponding ${ACTUAL} files."
    echo "  -o  When testing, ignore the order of lines in the file."
    echo "      This is accomplished by sorting the expected and actual outputs before comparing"
    echo "  -w  When testing, ignore extraneous whitespace differences between the expected and actual output."
    echo ""
}

#
# Process command-line arguments
#
OPTIND=1
while getopts "h?t:s:cuow" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    t)  TEST_DIR=${OPTARG}
        ;;
    s)  EXE_DIR=$OPTARG
        ;;
    c)  CLEAR_ACTUAL_FILES="YES"
        ;;
    u)  UPDATE_EXPECTED_FILES="YES"
        ;;
    o)  IGNORE_ORDER="YES"
        ;;
    w)  IGNORE_WHITESPACE="YES"
        ;;
    esac
done

#
# Convert input directories to absolute paths
#
TEST_DIR=$( pushd ${TEST_DIR} &> /dev/null ; pwd ; popd &> /dev/null )
EXE_DIR=$(  pushd ${EXE_DIR} &> /dev/null  ; pwd ; popd &> /dev/null )

#
# Find all test sub-directories
#
TEST_DIRECTORIES=$(find ${TEST_DIR} -type d -mindepth 1 -maxdepth 1)

#
# Make sure the user didnt specify both cleanup and update mode at the same time
#
if [ "${CLEAR_ACTUAL_FILES}" == "YES" ]; then
    if [ "${UPDATE_EXPECTED_FILES}" == "YES" ]; then
        echo "Cannot run tatt in cleanup and update mode simultaneously."
        exit 1
    fi
fi

#
# Run in cleanup mode, if specified by the user
#
if [ "${CLEAR_ACTUAL_FILES}" == "YES" ]; then
    echo "Cleaning up all ${ACTUAL} files..."
    rm -f $( find ${TEST_DIR} | grep "${ACTUAL}" )
    exit 0
fi

#
# Run in update mode, if specified by the user
#
if [ "${UPDATE_EXPECTED_FILES}" == "YES" ]; then
    echo "Updating contents of expcted.txt files..."
    for TD in ${TEST_DIRECTORIES} ; do
        pushd ${TD} &> /dev/null
        if [ -f ${ACTUAL} ]; then
            cp ${ACTUAL} ${EXPECTED}
        fi
        popd &> /dev/null
    done
    exit 0
fi

#
# Run each test
#
for TD in ${TEST_DIRECTORIES} ; do
    
    pushd ${TD} &> /dev/null
    
    TEST_NAME=$(basename ${TD})

    rm -f ${ACTUAL}
    while read LINE ; do
        COMMAND=${LINE/COMMAND_BASE_DIR/${EXE_DIR}}
        ${COMMAND} >> ${ACTUAL}
    done < command.txt

    DIFF_CMD=diff
    OUTPUT_DUMP_CMD=cat
    if [ "${IGNORE_ORDER}" == "YES" ]; then
        OUTPUT_DUMP_CMD=sort
    fi
    if [ "${IGNORE_WHITESPACE}" == "YES" ]; then
        DIFF_CMD="${DIFF_CMD} -b -w"
    fi
    
    ${OUTPUT_DUMP_CMD} ${EXPECTED} > /tmp/${EXPECTED}
    ${OUTPUT_DUMP_CMD} ${ACTUAL} > /tmp/${ACTUAL}

    DIFF=$(${DIFF_CMD} /tmp/${EXPECTED} /tmp/${ACTUAL}) 
    if [ "${DIFF}" == "" ] 
    then
        echo "Test ${TEST_NAME} passed!"
    else
        echo "Test ${TEST_NAME} failed with the following diff:"
        echo "${SEPARATOR}"
        echo ""
        echo "${DIFF}"
        ${DIFF_CMD} -c /tmp/${EXPECTED} /tmp/${ACTUAL}
        echo ""
        echo "${SEPARATOR}"
    fi
    
    popd &> /dev/null

done

