### This works around the opam file encoded depext llvm3.4 dependency by simply not using depext to install bap itself.

`sudo apt-get install clang dejagnu libcurl4-gnutls-dev libgmp-dev libzip-dev ncurses-dev pkg-config zlib1g-dev binutils binutils-dev python`

`sudo apt-get install llvm-3.8 llvm-3.8-dev`

`wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh`

`chmod 777 opam_installer.sh`

`./opam_installer.sh /usr/local/bin 4.02.3`

`opam pin add bap --dev-repo`

#Get objdump symbolizer as option (assuming above installed binutils)

`opam depext --install conf-binutils`

#Get ida pro symbolizer (assuming system copy of IDA Pro already installed)

`opam depext --install conf-ida`

#Install bap and ida pro bindings/pluginstuff
```
opam install bap bap-ida-python

eval `opam config env`
```