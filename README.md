# About this repository

This is the Git repository of the docker image for MonaTiny.

**You can browse the branches of docker-mona to find the distribution and project that you want.**


## Usage

Install docker and run the following command to get the MonaServer image :

```
docker pull thomasjammet/docker-mona:alpine-monatiny
```

Then start your MonaServer image with the command below :

```
docker run -it --name MonaTiny -p 80:80 -p 1935:1935 -p 443:443 -p 1935:1935/udp thomasjammet/docker-mona:alpine-monatiny
```
