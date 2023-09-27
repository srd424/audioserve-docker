all: trunk

client: .client

OPTSFILE=sd
include buildopts/$(OPTSFILE).mk

.client: Dockerfile.client Makefile
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		$(OPTS) \
		--build-arg tag=trunk \
		-v $$PWD/client-out:/client-out \
		-f Dockerfile.client $$PWD
	touch .client

trunk: client Dockerfile Makefile
	time nice -n +10 ionice -c 2 -n 7 buildah bud \
		$(OPTS) \
		--build-arg tag=trunk \
		-t as-docker \
		-v $$PWD/client-out:/audioserve_client \
		--platform linux/arm64 \
		-f Dockerfile $$PWD
