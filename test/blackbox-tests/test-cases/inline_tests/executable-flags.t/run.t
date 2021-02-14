This test ensures that compilation fails when an invalid option is supplied
to flags field in executable field in inline_tests field.

First, we pass a valid option to flags field expecting compilation
to be successful.

  $ dune runtest valid_options --root ./test-project
  Entering directory 'test-project'
  inline_test_runner_valid_option_test alias valid_options/runtest
  backend_foo

Lastly, we pass an invalid option to flags field expecting compilation
to fail.

  $ output=$(dune runtest invalid_options --root ./test-project 2>&1); result=$?; (echo $output | grep -o "unknown option '-option-that-is-not-accepted-by-ocaml'."); (exit $result)
  unknown option '-option-that-is-not-accepted-by-ocaml'.
  [1]

Do not warn when there is a unused open module in the inline tests.
Protects against the regression reported in
https://github.com/ocaml/dune/issues/4177

  $ dune runtest open_opt --root ./test-project
  Entering directory 'test-project'
  inline_test_runner_test_foo alias open_opt/runtest
  unused_open_backend
