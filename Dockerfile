FROM ubuntu:lunar AS audioserve-client
ARG apt_proxy
ARG tag
RUN { [ -n "$apt_proxy" ] && echo "Acquire::http::proxy \"$apt_proxy\";" >/etc/apt/apt.conf.d/02proxy; } || true
RUN apt-get update && apt-get install -y --no-install-recommends eatmydata
RUN eatmydata apt-get install -y --no-install-recommends \
	npm git
RUN git clone https://github.com/izderadicka/audioserve-web.git /audioserve_client && \
    cd /audioserve_client && \
    npm install && \
    npm run build && \
    npm run build-sw && \
    mv public dist


FROM ubuntu:jammy AS final
ARG apt_proxy
ARG tag
RUN { [ -n "$apt_proxy" ] && echo "Acquire::http::proxy \"$apt_proxy\";" >/etc/apt/apt.conf.d/02proxy; } || true
COPY qemu-aarch64-static /usr/bin
RUN apt-get update && apt-get install -y --no-install-recommends eatmydata
RUN eatmydata apt-get install -y --no-install-recommends \
	libavformat58 libavcodec58 libavutil56 curl wget jq unzip \
	ca-certificates ffmpeg openssl
RUN latest=$(curl -s "https://api.github.com/repos/srd424/audioserve-builder/releases" | \
		 jq -r "[.[]|select(.tag_name|startswith(\"\"))][0].tag_name" ) && \
	curl -O -L https://github.com/srd424/audioserve-builder/releases/download/$latest/audioserve_aarch64.zip && \
	unzip audioserve_aarch64.zip && \
	mv /result /audioserve

RUN mkdir /ssl &&\
    cd /ssl &&\
    openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem \
        -subj "/C=CZ/ST=Prague/L=Prague/O=Ivan/CN=audioserve" &&\
    openssl pkcs12 -inkey key.pem -in certificate.pem -export  -passout pass:mypass -out audioserve.p12 

COPY --from=audioserve-client /audioserve_client/dist /audioserve/client/dist

WORKDIR /audioserve
EXPOSE 3000
ENTRYPOINT [ "./audioserve" ]


