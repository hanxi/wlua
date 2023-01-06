FROM ubuntu:22.04 AS builder

COPY . /wlua

RUN apt-get update && apt-get install -y \
    git libssl-dev build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    cd /wlua && make install WLUA_BIN=/usr/bin/wlua

FROM ubuntu:22.04

LABEL maintainer="im.hanxi@gmail.com"
LABEL version="0.0.2"
LABEL description="This is Docker Image for wlua"

RUN apt-get update && apt-get install -y \
    libssl3 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY --from=builder /usr/bin/wlua /usr/bin/wlua
COPY --from=builder /usr/local/wlua /usr/local/wlua

CMD [ "bash" ]
