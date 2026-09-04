# Getting latest development version

We have the opam-repository that is automatically updated with the new version of bap every time we merge a PR to the master branch (in fact it just pulls the source code from the master branch of BAP upstream repository). Therefore to get access to the latest development of BAP just add it to the list of your opam repositories, with the following command:
```
opam repo add bap-testing git+https://github.com/BinaryAnalysisPlatform/opam-repository#testing
```

and then you can do
```
opam install bap
```

to get the latest version of BAP, or, if you miss the system dependencies,
```
opam depext --install bap
```


# Building BAP repository

Disclaimer, it is easier to build and install bap using opam. But if you really want to have the source code of bap and an ability to modify and reinstall it, here are simple instructions.

```
opam switch create 4.09.0 # creates a new switch
eval $(opam env) # activates the opam switch
git clone git@github.com:BinaryAnalysisPlatform/bap.git
cd bap
# the next three commands will install bap dependencies (but not bap) from opam
opam pin add file://. -n
opam depext bap # installs the system dependencies
opam install bap --deps-only # installs OCaml dependencies
opam install merlin ocp-indent # (optional) useful developers tools
opam pin remove bap

# install ghidra debian package or pass --disable-ghidra to configure in the next step
sudo add-apt-repository ppa:ivg/ghidra -y
sudo apt install libghidra-dev -y
sudo apt install libghidra-data

# enables every bap component and sets up llvm
./configure --enable-everything --prefix=`opam config var prefix` --with-llvm-version=9 --with-llvm-config=llvm-config-9
make && make reinstall
```

# Setting/Changing the LLVM version

You can set the LLVM version before BAP is installed using the
opam configuration parameter `llvm-config`,

```
opam config set llvm-config <path-to-llvm-config>
```

E.g.,

```
opam config set llvm-config llvm-config-9
```

You can specify a full path, if you want to use local installation.

If bap is already installed or if it is partially installed, then you need to
reinstall the conf-bap-llvm for the changes to take the effect,

```
opam reinstall conf-bap-llvm
```

This command will propagate the change to all dependent packages.

Note, if your installation of BAP failed and you decided to try it
with another version of LLVM, them issuing `opam install bap` will
resume from the place where it has failed.

# Staying in sync

To update to the latest available version of BAP issue the following two commands:

```shell
opam update bap
opam upgrade
```

If you don't want to upgrade all your opam stack, then you can upgrade just bap,

```shell
opam upgrade bap
```


# Installing on other operating systems

We believe that BAP can be installed on any system with recent compiler toolchain. The hardiest problem is to install system dependencies. As a stating approximation, you can take a look at our system dependencies on Ubuntu 14.04, and extrapolate them to your system,

```shell
opam list --safe --recursive --external=ubuntu --required-by=bap
```

If you managed to install BAP on another system, please share your success story with us!
