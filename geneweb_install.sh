#!/usr/bin/env bash

# Get latest geneweb source code from github
git clone https://github.com/geneweb/geneweb /home/geneweb/source
cd /home/geneweb/source
git checkout ac3546e783eec1bcbd91493186e6d8d6e4e8d157

# Init opam and switch to 4.09
opam init --yes --disable-sandboxing
eval $(opam env)
opam switch --yes create 4.12.1
eval $(opam env)
opam install --yes benchmark camlp5.8.00.01 cppo dune jingoo markup stdlib-shims num unidecode uucp uunf zarith calendars syslog ppx_blob ppx_import
eval $(opam env)

# Build geneweb from source
cd /home/geneweb/source
ocaml ./configure.ml --sosa-zarith
make distrib
