# What is this?
Some people have difficulty installing BAP, just want to try it out quickly, or for whatever reason like containerized dev environments. This page is meant to assist them by explaining how to install BAP via Docker, which will skip most of the difficulty of dealing with dependencies/compilation.

If you already know what you're doing, the you're looking for ```binaryanalysisplatform/bap``` or ```binaryanalysisplatform/bap:1.0.0```. Otherwise, read on...

# Docker
Docker is a container solution (think lightweight VM) for Linux, but is available for Windows and Mac via actual virtualization.

## Linux
Install via your package manager if possible (this should be available on most distros). Otherwise, you can use the pieces of a docker install from [here](https://docs.docker.com/installation/binaries/). Beware, this is potentially complex.

## OS X
Grab the [OS X Installer](https://docs.docker.com/installation/mac/). This should go smoothly, the three people I've tested with have all had success.

## Windows
Grab the [Windows Installer](https://docs.docker.com/installation/windows/). I have no experience with this version of docker, but I have no reason to believe it will not work.

# BAP Containers

Docker containers with git or latest bap are available via [Dockerhub](https://registry.hub.docker.com/u/binaryanalysisplatform/bap/).
```binaryanalysisplatform/bap:git``` should contain the latest Git master, and ```binaryanalysisplatform/bap:1.0.0``` the latest release. For the moment these are the same, but they may diverge in the future.

Once you have docker installed, you should be able to run
```
docker run  binaryanalysisplatform/bap:latest bap /bin/ls -dasm
```

For further information on how to use docker containers (such as how to persist your environment) see the [Docker Documentation](https://docs.docker.com/userguide/).

## Building
If for some reason you want to build locally, you can use our ```Dockerfile`` (https://github.com/BinaryAnalysisPlatform/bap/blob/master/docker/Dockerfile).

You shouldn't need to do this, as I've instructed Dockerhub to automatically build off the repo and store the results for you.
