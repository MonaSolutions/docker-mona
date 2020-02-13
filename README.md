# About this repository

This is the Git repository of the docker image for MonaServer.

**You can browse the branches of docker-mona to find the distribution and project that you want.**


## Usage

Install docker and run the following command to get the MonaServer image :

```
docker pull monaserver/monaserver
```

Or pull another branch by specifying the tag name. For example this command pull the MonaTiny image :

```
docker pull monaserver/monaserver:alpine-monatiny
```

Then start your MonaServer image with the command below :

```
docker run -it --name Mona -p 80:80 -p 1935:1935 -p 554:554 -p 1935:1935/udp monaserver/monaserver
```

Or for example if you want to run MonaTiny image, use this command :

```
docker run -it --name MonaTiny -p 80:80 -p 1935:1935 -p 443:443 -p 1935:1935/udp monaserver/monaserver:alpine-monatiny
```

### Volumes

You may need to mount app folder to /usr/local/bin/www. For this run the following command :

```
docker run --rm -it --name Mona -p 80:80 -p 1935:1935 -p 443:443 -p 1935:1935/udp -v /path/on/your/host:/usr/local/bin/www monaserver/monaserver
```

**Note:** If we you are running Docker on Windows all containers run on VirtualBox so you need to add the host path in VirtualBox and restart the Docker machine.

### Logs

If a monaserver container run in interactive mode (`-it`) the logs will be available in the console.

With the detach mode (`-d`) the `docker logs <IMAGE NAME>` will not show anything because MonaServer does not redirect the logs to /dev/stdout. 
In this case it is possible to watch the logs in the *MonaServer.log/* directory. For example the following command will show the last logs using `tail` :

```
docker exec mona tail -f /usr/local/bin/MonaTiny.log/0.log
```
