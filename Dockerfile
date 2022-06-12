FROM ubuntu:jammy AS buildenv
ARG apt_proxy
RUN { [ -n "$apt_proxy" ] && echo "Acquire::http::proxy \"$apt_proxy\";" >/etc/apt/apt.conf.d/02proxy; } || true
COPY qemu-aarch64-static /usr/bin
RUN apt-get update && apt-get install -y --no-install-recommends eatmydata
RUN eatmydata apt-get install -y --no-install-recommends \
	libavformat58 libavcodec58 libavutil56 curl wget jq unzip \
	ca-certificates ffmpeg openssl
RUN latest=$(curl -s "https://api.github.com/repos/srd424/audioserve-builder/releases/latest" | \
		 jq -r .tag_name) && \
	curl -O -L https://github.com/srd424/audioserve-builder/releases/download/$latest/audioserve_aarch64.zip && \
	unzip audioserve_aarch64.zip && \
	mv /result /audioserve

RUN mkdir /ssl &&\
    cd /ssl &&\
    openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem \
        -subj "/C=CZ/ST=Prague/L=Prague/O=Ivan/CN=audioserve" &&\
    openssl pkcs12 -inkey key.pem -in certificate.pem -export  -passout pass:mypass -out audioserve.p12 

WORKDIR /audioserve
EXPOSE 3000
ENTRYPOINT [ "./audioserve" ]

#COPY sources.list /etc/apt/sources.list
#RUN dpkg --add-architecture arm64 && \
#        apt-get update || true
#RUN apt-get install -y --no-install-recommends eatmydata
#RUN eatmydata apt-get install -y --no-install-recommends \
#                git ca-certificates \
#                cargo \
#                libstd-rust-dev:arm64 \
#                gcc-aarch64-linux-gnu \
#                pkg-config \
#                libc6-dev-arm64-cross \
#                libssl-dev \
#                libssl-dev:arm64 \
#                libavformat-dev:arm64 \
#		npm
#RUN rm -f /var/cache/apt/archives/*.deb
#COPY cargo-config /cargo-config
#COPY build.sh /
#RUN chmod a+x /build.sh
#CMD /build.sh
#
