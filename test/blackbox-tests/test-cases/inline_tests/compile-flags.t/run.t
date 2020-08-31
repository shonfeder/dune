This test ensures that compilation fails when an invalid flag is supplied
to compile_flags field.

First, we pass a valid flag to compile_flags field expecting compilation
to be successful.

  $ dune runtest valid_flags --root ./test-project
  Entering directory 'test-project'
  inline_test_runner_valid_compile_flags_test alias valid_flags/runtest
  backend_foo

Lastly, we pass an invalid flag to compile_flags field expecting compilation
to fail.

  $ output=$(dune runtest invalid_flags --root ./test-project 2>&1); result=$?; (echo $output | grep -o "unknown option '-flag-that-is-not-accepted-by-ocaml'."); (exit $result)
  unknown option '-flag-that-is-not-accepted-by-ocaml'.
  [1]
