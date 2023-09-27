FROM ubuntu:jammy AS final
ARG apt_proxy
ARG tag
RUN { [ -n "$apt_proxy" ] && echo "Acquire::http::proxy \"$apt_proxy\";" >/etc/apt/apt.conf.d/02proxy; } || true
COPY qemu-aarch64-static /usr/bin
RUN apt-get update && apt-get install -y --no-install-recommends eatmydata
RUN eatmydata apt-get install -y --no-install-recommends \
	curl wget jq unzip ca-certificates
RUN eatmydata apt-get install -y --no-install-recommends \
	libavformat58 libavcodec58 libavutil56 ffmpeg openssl
RUN latest=$(curl -s "https://api.github.com/repos/srd424/audioserve-builder/releases" | \
		 jq -r "[.[]|select(.tag_name|startswith(\"$tag\"))][0].tag_name" ) && \
	echo "fetching tag $latest" && \
	curl -O -L https://github.com/srd424/audioserve-builder/releases/download/$latest/audioserve_aarch64.zip && \
	unzip audioserve_aarch64.zip && \
	mv /result /audioserve

RUN mkdir /ssl &&\
    cd /ssl &&\
    openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem \
        -subj "/C=CZ/ST=Prague/L=Prague/O=Ivan/CN=audioserve" &&\
    openssl pkcs12 -inkey key.pem -in certificate.pem -export  -passout pass:mypass -out audioserve.p12 

RUN mkdir -p /audioserve/client && \
	cp -av /audioserve_client/dist /audioserve/client/dist

WORKDIR /audioserve
EXPOSE 3000
ENTRYPOINT [ "./audioserve" ]


