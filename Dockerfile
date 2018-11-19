# 
# MonaTiny Dockerfile

FROM alpine 

MAINTAINER Thomas Jammet contact@monaserver.ovh 

# install prerequisites 
RUN apk add --no-cache libgcc \
    libstdc++ \
    openssl-dev \
  && apk add --no-cache --virtual .build-deps \
    curl \
    make \
    g++ \
# Build & install MonaTiny 
  && curl -SL -o mona.tar.gz https://github.com/MonaSolutions/MonaServer2/archive/master.tar.gz \
  && tar -xzf mona.tar.gz \
  && rm mona.tar.gz \
  && cd MonaServer2-master \
  && cd MonaBase && make && cd ../MonaCore && make && cd ../MonaTiny && make \
  && cp ../MonaBase/lib/libMonaBase.so ../MonaCore/lib/libMonaCore.so /usr/local/lib \
  && cp MonaTiny /usr/local/bin \
  && mkdir /usr/local/share/MonaTiny \
  && cp cert.pem key.pem /usr/local/share/MonaTiny \
  && printf ";MonaTiny configuration file\nbufferSize=2097120\n" > /usr/local/share/MonaTiny/MonaTiny.ini \
  && rm -Rf /MonaServer2-master \
  && apk del .build-deps 
  
WORKDIR /usr/local/share/MonaTiny

EXPOSE 80 1935 443 

# Set MonaServer as default executable 
CMD ["/usr/local/bin/MonaTiny", "--log=7"]
