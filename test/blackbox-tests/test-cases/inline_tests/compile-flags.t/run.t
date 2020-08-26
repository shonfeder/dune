This test ensures that compilation fails when an invalid flag is supplied
to compile_flags field.

First, we pass a valid flag to compile_flags field expecting compilation
to be successful.

  $ dune runtest dune-file-with-valid-flag
  inline_test_runner_compile_flags_test alias dune-file-with-valid-flag/runtest
  backend_foo

Lastly, we pass an invalid flag to compile_flags field expecting compilation
to fail.

  $ output=$(dune runtest dune-file-with-invalid-flag 2>&1); result=$?; (echo $output | grep -o "unknown option '-flag-that-is-not-accepted-by-ocaml'."); (exit $result)
  unknown option '-flag-that-is-not-accepted-by-ocaml'.
  [1]
