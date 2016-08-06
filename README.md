# About this repository

This is the Git repository of the docker image for MonaServer.

## Usage

Install docker and run the following command to get the MonaServer image :

```
docker pull thomasjammet/docker-mona
```

Then start your MonaServer image with the command below :

```
docker run -it --name Mona -p 80:80 -p 1935:1935 -p 554:554 -p 1935:1935/udp thomasjammet/docker-mona
```
