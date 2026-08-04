When running in a sandbox, Dune must preserve the path to the installed
compiler's standard library. Compilers installed as a regular package live
inside the build directory and a relocatable compiler locates its stdlib
relative to its own executable path. When Dune executes sandboxed programs
[Sys.argv.(0)] is set to the unresolved sandbox path, so the stdlib must be
present in the sandbox. (On macos, [Sys.executable_name] retains the symlink,
which is where the bug was first observed in
https://github.com/ocaml/dune/issues/15642, but a shell wrapper reading [$0]
reproduces the same property on every unix-like system.)

Create a relocatable compiler wrapper which delegates to the test compiler,
deliberately locating its standard library relative to its own path, as a
compiler configured with --with-relative-libdir does:

  $ real_ocaml_bin=$(dirname "$(command -v ocamlc)")
  $ real_ocaml_lib=$(ocamlc -where)
  $ real_menhir=$(command -v menhir)
  $ ocaml_version=$(ocamlc -version)

  $ mkdir fake-compiler
  $ {
  >   echo '#!/bin/sh'
  >   echo "real_ocaml_bin='$real_ocaml_bin'"
  >   cat <<'EOF'
  > tool=$(basename "$0")
  > case "$tool" in
  > ocamlc | ocamlc.opt | ocamlopt | ocamlopt.opt)
  >   self_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  >   OCAMLLIB="$self_dir/../lib/ocaml"
  >   export OCAMLLIB
  >   ;;
  > esac
  > exec "$real_ocaml_bin/$tool" "$@"
  > EOF
  > } > fake-compiler/compiler
  $ chmod +x fake-compiler/compiler

  $ mkdir fake-menhir
  $ {
  >   echo '#!/bin/sh'
  >   echo "exec '$real_menhir' \"\$@\""
  > } > fake-menhir/menhir
  $ chmod +x fake-menhir/menhir

The relocatable-compiler marker package in the dependency closure makes Dune
install the compiler as a regular package rather than through the
non-relocatable toolchain mechanism:

  $ make_lockdir
  $ cat >> dune.lock/lock.dune <<'EOF'
  > (ocaml ocaml-base-compiler)
  > EOF

  $ make_lockpkg relocatable-compiler <<EOF
  > (version $ocaml_version)
  > EOF

  $ make_lockpkg ocaml-base-compiler <<EOF
  > (version $ocaml_version)
  > (depends relocatable-compiler)
  > (install
  >  (progn
  >   (run mkdir -p %{prefix}/bin %{prefix}/lib/ocaml)
  >   (run sh -c
  >    "for t in ocamlc ocamlc.opt ocamldep ocamldep.opt ocamlmklib \
  >       ocamlobjinfo ocamlopt ocamlopt.opt ocaml; \
  >     do cp compiler %{prefix}/bin/\$t; done")
  >   (run cp $real_ocaml_lib/Makefile.config
  >        %{prefix}/lib/ocaml/Makefile.config)
  >   (run sh -c "cp $real_ocaml_lib/*.cmi %{prefix}/lib/ocaml")))
  > (source (copy $PWD/fake-compiler))
  > EOF

  $ make_lockpkg menhir <<EOF
  > (version 1)
  > (install
  >  (progn
  >   (run mkdir -p %{prefix}/bin)
  >   (run cp menhir %{prefix}/bin/menhir)))
  > (source (copy $PWD/fake-menhir))
  > EOF

  $ cat > dune-project <<'EOF'
  > (lang dune 3.24)
  > (using menhir 2.0)
  > (package
  >  (name repro)
  >  (allow_empty)
  >  (depends ocaml-base-compiler menhir))
  > EOF

  $ cat > dune-workspace <<'EOF'
  > (lang dune 3.24)
  > (pkg enabled)
  > (context default)
  > EOF

  $ cat > dune <<'EOF'
  > (library
  >  (name repro))
  > (menhir
  >  (modules parser))
  > EOF

  $ cat > parser.mly <<'EOF'
  > %token <int> INT
  > %token EOF
  > %start <int> main
  > %%
  > main:
  > | i = INT EOF { i + 1 }
  > EOF

Show the undesirable failure we need to fix:

  $ dune build _build/default/parser__mock.mli.inferred
  File "command line", line 1:
  Error: Unbound module Stdlib
  [1]
