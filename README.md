# TATT

![Test All The Things](./images/test-all-the-things.jpg)


## About

TATT stands for "Test All The Things".
Tatt is a simple framework for end-to-end software testing.
It was specifically designed for testing student homeworks for my courses, but it is designed to also work well as a general-purpose end-to-end test framework.
Tatt is particularly good at testing programs that can be easily executed on the command line (via bash, sh, etc.) and whose output is sent to a file and/or stdout.
This framework is _not_ particularly good for testing visual output, graphics, or web applications.
If these are your needs, look elsewhere!


## Writing Tests

Tatt is used by creating a single directory full of subdirectories, and each subdirectory represents a single tatt test case.
Each individual test directory should contain the following files:

* `command.txt` : This file should contain a single line, which is the shell command that should be executed as a test.
                  Tatt will execute the content of this file, exactly as written, in a new shell.
                  The one exception is that `commands.txt` may use the token `COMMAND_BASE_DIR`, and Tatt will replace this with the directory specified to the `-s` option of tatt.
* `expected.txt` : A text file containing the expected output of this particular execution of your program.

Each test directory should also contain any necessary resource files needed for the test, such as input files.

A top-level test directory will have a structure that looks similar to this:

```
$ tree tests/
tests/
├── some-test
│   ├── resource-1.txt
|   ├── resource-2.txt
│   ├── command.txt
│   └── expected.txt
├── another-test
│   ├── resource-X.txt
│   ├── command.txt
│   └── expected.txt
└── cool-test
    ├── command.txt
    └── expected.txt
```

Tatt will generate an `actual.txt` alongside each `expected.txt` after being executed.
The `actual.txt` is the captured stdout from running the command in `command.txt`.
Tatt will diff `actual.txt` and `expected.txt`.
If they are identical, then the test "passes."
If there are any differences, the test will fail and the diff will be printed.

See the `tatt/tests` directory for a few example test cases.

## Usage

To use, just run `tatt.sh`.
See `tatt.sh -h` for details of command-line options.


## Testing

Tatt has a default test suite, located in the `./tests`.
Since tatt itself is a testing framework, we use tatt to test itself.
To run the tatt tests, just execute:

```
./tatt.sh
```

