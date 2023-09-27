Docker image for aarch64 builds based on the binaries built by https://github.com/srd424/audioserve-builder.

Command line arguments should be the same as for upstream, see https://github.com/izderadicka/audioserve#docker-image

The new web client is now built, note that it effectively requires https or you cannot login!

Pull from Github Package's repo: https://github.com/srd424/audioserve-docker/pkgs/container/audioserve-docker

e.g., for a specific version:

 docker pull ghcr.io/srd424/audioserve-docker:v0.17.0
 
 OR

 docker pull ghcr.io/srd424/audioserve-docker:latest

(this may include unversioned builds of the current upstream main/master branch occasionally, if I decide there are useful fixes/features that are worth having before an official release.)
