all: trunk

client: .client

.client: Dockerfile.client Makefile
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		--build-arg apt_proxy=http://fs2.lan:3142/ \
		--build-arg tag=trunk \
		-f Dockerfile.client $$PWD
	touch .client
#		-v $$PWD/client-out:/client-out \

trunk: client Dockerfile Makefile
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		--build-arg apt_proxy=http://fs2.lan:3142/ \
		--build-arg tag=trunk \
		-t as-docker \
		-v $$PWD/client-out:/audioserve_client \
		--platform linux/arm64 \
		-f Dockerfile $$PWD
