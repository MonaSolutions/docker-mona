#
# MonaServer2 Dockerfile

FROM alpine

LABEL maintainer="Thomas Jammet <contact@monaserver.ovh>"

ENV LUAJIT_VERSION 2.1.0-beta3
ENV LUAJIT_DOWNLOAD_SHA256 1ad2e34b111c802f9d0cdf019e986909123237a28c746b21295b63c9e785d9c3

# install prerequisites
RUN apk add --no-cache libgcc \
		libstdc++ \
		openssl-dev \
	&& apk add --no-cache --virtual .build-deps \
		curl \
		make \
		g++ \
		git \
# Build & install luajit
	&& mkdir -p /usr/src \
	&& cd /usr/src \
	&& curl -fSL -o luajit.tar.gz http://luajit.org/download/LuaJIT-$LUAJIT_VERSION.tar.gz \
	&& echo "$LUAJIT_DOWNLOAD_SHA256 *luajit.tar.gz" | sha256sum -c \
	&& tar -xzf luajit.tar.gz \
	&& rm luajit.tar.gz \
	&& cd LuaJIT-$LUAJIT_VERSION \
	&& sed -i 's/#XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/g' src/Makefile \
	&& make \
	&& make install \
	&& cd ../ \
	&& rm -Rf LuaJIT-$LUAJIT_VERSION \
# Build & install MonaServer
	&& git clone https://github.com/MonaSolutions/MonaServer2.git \
	&& cd MonaServer2 \
	&& cd MonaBase && make && cd ../MonaCore && make && cd ../MonaServer && make\
	&& cp ../MonaBase/lib/libMonaBase.so ../MonaCore/lib/libMonaCore.so /usr/local/lib \
	&& cp MonaServer /usr/local/bin \
	&& rm -Rf /usr/src/MonaServer2 \
	&& apk del .build-deps

WORKDIR /usr/local/bin

EXPOSE 80 1935 443 3478

# Set MonaServer as default executable
CMD ["./MonaServer", "--log=7"]