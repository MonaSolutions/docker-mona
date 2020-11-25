#
# MonaServer2 Dockerfile

FROM alpine:latest AS builder

LABEL maintainer="Thomas Jammet <contact@monaserver.ovh>"

ENV LUAJIT_VERSION 2.1.0-beta3
ENV LUAJIT_DOWNLOAD_SHA256 1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3

# install prerequisites
RUN apk add --no-cache libgcc \
		libstdc++ \
		openssl-dev

RUN apk add --no-cache --virtual .build-deps \
		curl \
		make \
		g++ \
		git

# Build & install luajit
WORKDIR /usr/src
RUN curl -fSL -o luajit.tar.gz http://luajit.org/download/LuaJIT-$LUAJIT_VERSION.tar.gz \
	&& echo "$LUAJIT_DOWNLOAD_SHA256 *luajit.tar.gz" | sha256sum -c \
	&& tar -xzf luajit.tar.gz \
	&& cd LuaJIT-$LUAJIT_VERSION \
	&& sed -i 's/#XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/g' src/Makefile \
	&& make \
	&& make install

# Build
RUN git clone https://github.com/MonaSolutions/MonaServer2.git
WORKDIR /usr/src/MonaServer2/MonaBase
RUN make 
WORKDIR /usr/src/MonaServer2/MonaCore
RUN make
WORKDIR /usr/src/MonaServer2/MonaServer
RUN make

# install MonaServer
RUN cp ../MonaBase/lib/libMonaBase.so ../MonaCore/lib/libMonaCore.so /usr/local/lib \
	&& cp MonaServer ../MonaTiny/cert.pem ../MonaTiny/key.pem /usr/local/bin

# No need to delete build tools with the multi-stage build

##################################################
# Create a new Docker image with just the binaries
FROM alpine:latest

RUN apk add --no-cache libgcc libstdc++

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

WORKDIR /usr/local/bin

# Set MonaServer as default executable
CMD ["./MonaServer", "--log=7"]

