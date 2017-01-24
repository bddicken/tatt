#!/bin/bash

# Initialize our own option variables
TEST_DIR="./tests"
EXE_DIR="./"

show_help() {
    echo "usage: ./tatt.sh [args]"
    echo ""
    echo "args:"
    echo "  -h  Show this help message."
    echo "  -t  Specify the directory containing tests directories to run."
    echo "      Default: ${TEST_DIR}"
    echo "  -s  Specify the directory to find the program/script that the tests execute."
    echo "      Default: ${EXE_DIR}"
    echo ""
}


# A POSIX variable
# Reset in case getopts has been used previously in the shell.
OPTIND=1
# Process the options
while getopts "h?t:s:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    t)  TEST_DIR=${OPTARG}
        ;;
    s)  EXE_DIR=$OPTARG
        ;;
    esac
done

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#pushd ${DIR} &> /dev/null

TEST_DIRECTORIES=$(find ${TEST_DIR} -type d -mindepth 1 -maxdepth 1)

for TD in ${TEST_DIRECTORIES} ; do
    pushd ${TD} &> /dev/null
    PRE_COMMAND=$(cat command.txt)
    COMMAND=${PRE_COMMAND/COMMAND_BASE_DIR/${EXE_DIR}}
    ${COMMAND} > actual.txt
    DIFF=$(diff expected.txt actual.txt) 
    if [ "${DIFF}" == "" ] 
    then
        echo "Test ${TD} passed!"
    else
        echo "Test ${TD} failed with the following diff:"
        echo ""
        echo "${DIFF}"
        echo ""
    fi
    popd &> /dev/null
done

#popd &> /dev/null

