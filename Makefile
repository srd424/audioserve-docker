all:
	time nice -n +10 ionice -c 2 -n 7 buildah bud --build-arg apt_proxy=http://fs2.lan:3142/ -f Dockerfile
