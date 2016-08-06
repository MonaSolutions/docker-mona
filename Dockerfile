#
# MonaServer Dockerfile
# Version 1

FROM alpine

MAINTAINER Thomas Jammet contact@monaserver.ovh

# install prerequisites 
RUN apk update && apk add --no-cache --virtual .build-deps git make g++ openssl-dev 

# Build luajit
WORKDIR /var/local
RUN git clone http://luajit.org/git/luajit-2.0.git luajit
WORKDIR luajit
RUN sed -i 's/#XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/XCFLAGS+= -DLUAJIT_ENABLE_LUA52COMPAT/g' src/Makefile
RUN make && make install

# Build MonaServer
WORKDIR ../
RUN git clone https://github.com/MonaSolutions/MonaServer.git
WORKDIR MonaServer
RUN make INCLUDES="-I/usr/local/include/" # don't know why /usr/local/include/ is ignored by default

# Set MonaServer as default executable
WORKDIR MonaServer

EXPOSE 80 1935 554

CMD ["./MonaServer", "--log=7"]
