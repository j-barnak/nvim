# Running Bap from WSL with Windows 10 and IDA Pro

This is how a co-worker and I got BAP running from WSL under Windows 10 so that we could use our current IDA Pro windows license and still benefit from using IDA as the symbolizer!  Hopefully everyone else can benefit too.

## WARNING:  This is not a supported use of the LXSS WSL technology.  Using windows mklink into the lxss like we do is an abuse of the filesystem abstractions and may break with any release of WSL.

**General troubleshooting:**
* The **FIRST** time you get IDA Pro to run in this manner, it will stall execution and complain about an existing idb file.  Just close the prompt window and everything will work from there on out.  I don't know why this occurs yet:).
* Sometimes the opam depext install command will segfault.  The problem seems to be related to Out-of-memory in a long compilation chain where WSL holds memory too long.
  * The solution is to simply close and re-open all Bash windows then run same command again.
* Using existing idb files DOES WORK with behavioral oddities and a WORKAROUND.
  * We are still troubleshooting the problem but it likely revolves around the abuse of lxss and lxss metadata etc since IDA pro is creating the file outside of lxss.
  * The problem for bap is that it tries to call unlink on the drvfs file which is not supported correctly/currently by WSL.  You can work around this by setting BAP_IDA_DEBUG=3 which prevents BAP from trying to delete all the temp files.
  *  I believe the root problem is mentioned here :https://github.com/Microsoft/BashOnWindows/issues/966, and https://github.com/Microsoft/BashOnWindows/issues/2012.  I have tried installing the windows insider build with the fix in...but either...it's not in, or I don't understand the underlying nature of the problem with bap.  strace shows the unlink when compiling cmxs's is a problem even when bap is not trying to delete it's spare IDA files.


**Follow normal bap install instructions for bare BAP**

* I personally do an exotic install with llvm3.8 and the master branch using the --dev-repo install.
* I manually install all the deps with something like the following so I don't have to use depext to install BAP itself (and work around the llvm3.4 dependency)
  * I run `sudo apt-get install clang dejagnu libcurl4-gnutls-dev libgmp-dev libzip-dev ncurses-dev pkg-config zlib1g-dev`
* If using llvm3.8, add llvm3.8 to your path in the 'Update Path' step


**Create fake IDA directory in WSL/Bash**
```
mkdir ~/idabins
cd ~/idabins
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/idaq.exe idaq
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/idaq64.exe idaq64
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/idaw.exe idal
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/idaw64.exe idal64
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/cfg cfg
ln -s /mnt/c/Program\ Files\ \(x86\)/IDA\ 6.95/plugins plugins
```
**Update PATH variable in .bashrc**

`export PATH=$PATH:~/idabin`

If using llvm3.8: `export PATH=$PATH:/usr/lib/llvm-3.8/bin`

close and rerun your shell or `source ~/.bashrc`

**Change permissions in Windows IDA directory (base, cfg, and plugins)**

Use the gui to change permissions-->add modify and write to regular 'Users'

**Add a tmp dir mapping into lxss (This is not technically a supported mode.  Use at OWN RISK)**

**Start Admin cmd prompt and run the following replacing <User> with your user acct**

run `mklink /D C:\tmp C:\Users\<User>\AppData\Local\lxss\rootfs\tmp`

**Update locate DB so conf-ida will be happy**

`sudo updatedb`

**Update and install opam packages**
```
opam depext --install conf-binutils
opam depext --install conf-ida
opam install bap bap-ida-python
```

**Re-eval your opam stuff so bap will be available**
```
eval `opam config env`
```

**Work around to allow ida and bap to talk**

export BAP_IDA_DEBUG=3

IDA pro will complain about an idb already existing.  Just close the window or select leave unpacked.
Not the simplest workflow...but now you have windows IDA PRo symbolizer working with WSL/Bash BAP.