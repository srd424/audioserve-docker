all: trunk

client:
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		--build-arg apt_proxy=http://fs2.lan:3142/ \
		--build-arg tag=trunk \
		-t audioserve-client \
		-f Dockerfile.client $$PWD
trunk: client
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		--build-arg apt_proxy=http://fs2.lan:3142/ \
		--build-arg tag=trunk \
		-f Dockerfile $$PWD
