# General

### It doesn't compile

First of all, make sure that you're using the newest version. Sometimes, for some obscure
reasons, OPAM decides to install not the latest version of BAP. So if the error message says 
something like 
```
The following actions failed
  ∗  install bap 0.9.7
```

Or any other version that is less than 1.0.0, then you can try to force a correct version explicitly,
e.g.,

```
opam install 'bap>=1.0.0'
```

or

```
opam install bap.1.0.0
```


### Unsatisfied dependencies in OPAM

1. OPAM errored with a message, 
  ```
  The following dependencies couldn't be met
  ...
  ```
  Probably you have a wrong version of a compiler, try to switch to 4.02.3, with 

  ```
  opam switch 4.02.3
  eval `opam config env`
  ```

  Another possible cause of unresolved dependencies can be the constraint solver. OPAM works best
  with an external solver calls `aspcud`, so try to install it using your system package manager. 

2. OPAM failed to compile some of the dependencies

  If the failed package starts with the `conf-` prefix, then it means, that you lack some system dependency. 
  Try to install it using `opam depext` plugin, e.g., `opam depext conf-libcurl`. However, it might be the 
  case that your particular platform is not supported by the `conf` package. So in that case you need to figure
  out how to install it manually. 

  It is also possible, that some upstream package will break. Please, [report this issue][4] at least to our
  bug tracker, so that we can remove this version from our dependency set. It would be also a good
  idea to report the issue to the upstream repository maintainers. To get the issue tracker URL of the failed 
  package <PKG>, use the following command:
  ```
  opam show <PKG> | grep bug-reports
  ```
[4]: https://github.com/BinaryAnalysisPlatform/bap/issues

### LLVM is not found 

We can use llvm-3.4 or llvm-3.8 as our backend. Other versions are not supported (LLVM API is very unstable, so it is hard for us to follow all versions).

If you want to use llvm-3.8 you may use `opam depext --install conf-llvm.3.8` prior to running `opam install bap` to satisfy the requirements.  The default for the project is llvm3.4 but running the above will satisfy the dependency


# Linux

### OPAM is not available

If you don't have `opam`, available in a package manager of your Linux distribution, 
then you can use the following `ppa`, if you're on Ubuntu:

```
sudo add-apt-repository --yes ppa:avsm/ppa
```

For other distributions, please consult the [OPAM Installation][1] manual. They have a binary distribution, that might work on your distribution, otherwise building from sources should work. 

In case, if you really don't want to use `opam` you can still [install BAP from sources][3], as `opam` is not a requirement, it just makes life easier. 

[1]: https://opam.ocaml.org/doc/Install.html
[2]: https://github.com/BinaryAnalysisPlatform/bap/wiki/Build-tips-and-tricks#compiling-bap-from-a-source-tree

### bwrap: Failed to make / slave: Permission denied

By default, `opam` initialization includes a sandboxing step, which fails when installing into an unprivileged LXC container. This is easily evaded by disabling sandboxing:
```
rm -r ~/.opam
opam init --comp=4.09.0  --disable-sandboxing
```

See [ocaml/opam-repository#20093](https://github.com/ocaml/opam-repository/issues/20093) for details. 

# Mac OS X

## How to get external dependencies

Internally, we use [macports][3], once they are installed, you just need to install `opam`:

```
sudo port install opam
```

And then follow the instructions in the README, and OPAM will take care of the rest, including the external (aka system) dependencies.

[3]: https://www.macports.org/


## Compilation breaks on LLVM

First of all, make sure that you have LLVM installed. (The version that comes with mac os x, is not enough). Use [macports][3] to install `llvm-3.4` or `llvm-3.8` port. These are the versions that we understand. 

```
sudo port install llvm-3.4
```

If you're on brew, then make sure that `llvm-config` binary is in the PATH and has one of the specified above version. 


# Windows

## Is it possible at all?

Well, all things possible. We're specifically trying to use libraries, that are cross-platform, e.g., we use `Core_kernel` instead of `Core`. We are also trying to make our build system cross-platform. But, honestly speaking, we never tried to compile on Windows. So, if you want to try, don't hesitate to call for help, maybe together we will be able to install it on Windows. But don't expect an easy walk!