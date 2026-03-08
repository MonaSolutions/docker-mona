#
# MonaServer2 Dockerfile

FROM alpine:latest AS builder

ARG ENABLE_SRT=0

LABEL maintainer="Thomas Jammet <contact@monaserver.ovh>"

# install prerequisites
RUN apk add --no-cache libgcc \
		libstdc++ \
		luajit \
		libsrt

# install build dependencies
RUN apk add --no-cache --virtual .build-deps \
		curl \
		make \
		g++ \
		git \
		openssl-dev \
		luajit-dev \
		libsrt-dev

WORKDIR /usr/src

# clone source
RUN git clone https://github.com/MonaSolutions/MonaServer2.git
# fix musl compatibility
RUN find MonaServer2 -type f \( -name "*.cpp" -o -name "*.h" \) -exec sed -i 's/lseek64/lseek/g; s/off64_t/off_t/g' {} +

# build
WORKDIR /usr/src/MonaServer2
RUN make ENABLE_SRT=$ENABLE_SRT

# install MonaServer
RUN install -Dm755 MonaServer/MonaServer /usr/local/bin/MonaServer \
		&& install -Dm755 MonaTiny/MonaTiny /usr/local/bin/MonaTiny \
		&& install -Dm644 MonaTiny/cert.pem /usr/local/bin/cert.pem \
		&& install -Dm644 MonaTiny/key.pem /usr/local/bin/key.pem \
		&& install -Dm755 MonaBase/lib/libMonaBase.so /usr/local/lib/libMonaBase.so \
		&& install -Dm755 MonaCore/lib/libMonaCore.so /usr/local/lib/libMonaCore.so

# No need to delete build tools with the multi-stage build

##################################################
# Create a new Docker image with just the binaries
FROM alpine:latest

RUN apk add --no-cache libgcc \
		libstdc++ \
		luajit \
		libsrt

COPY --from=builder /usr/local/lib /usr/local/lib
COPY --from=builder /usr/local/bin /usr/local/bin

#
# Expose ports for MonaCore protocols
#

# HTTP(S)/WS(S)
EXPOSE 80/tcp
EXPOSE 443/tcp
# RTM(F)P
EXPOSE 1935/tcp
EXPOSE 1935/udp
# STUN
EXPOSE 3478/udp
# SRT
EXPOSE 9710/udp

WORKDIR /usr/local/bin

# Set MonaServer as default executable
CMD ["./MonaServer", "--log=7"]
