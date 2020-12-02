# 
# MonaTiny Dockerfile

FROM alpine AS builder

MAINTAINER Thomas Jammet contact@monaserver.ovh 

# install prerequisites 
RUN apk add --no-cache libgcc \
    libstdc++ \
    openssl-dev

RUN apk add --no-cache --virtual .build-deps \
    curl \
    make \
    g++

# Build MonaTiny 
WORKDIR /usr/src
RUN curl -SL -o mona.tar.gz https://github.com/MonaSolutions/MonaServer2/archive/master.tar.gz && tar -xzf mona.tar.gz
WORKDIR /usr/src/MonaServer2-master/MonaBase
RUN make
WORKDIR /usr/src/MonaServer2-master/MonaCore
RUN make
WORKDIR /usr/src/MonaServer2-master/MonaTiny
RUN make

# Install MonaTiny
RUN cp ../MonaBase/lib/libMonaBase.so ../MonaCore/lib/libMonaCore.so /usr/local/lib \
  && cp MonaTiny cert.pem key.pem /usr/local/bin \
  && printf ";MonaTiny configuration file\nbufferSize=2097120\n" > /usr/local/bin/MonaTiny.ini

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
CMD ["/usr/local/bin/MonaTiny", "--log=7"]
