# CompileLogging

## Only works if compiling with ninja!

# Vram swap setup using vramfs:

Create a folder for vram mount
Use the vramfs binary:
```shell
sudo ./path/vramfs/bin/vramfs /path/to/folder SizeOfMount -f
```

Once vramfs succesfully mounted createa a swap to it:
```shell
sudo dd if=/dev/zero of=/path/to/folder/swapfile bs=1M count=SIZE
sudo chmod 0600 /path/to/folder/swapfile
sudo mkswap /path/to/folder/swapfile
sudo losetup /dev/loop0 /path/to/folder/swapfile/swapfile
sudo swapon /dev/loop0
```


# How to use Single log:
Create a Docker Image from the docker file:
```shell
  docker build -t docker-image-name
```
*(This command is deprecated, and maybe removed in the future)*


**Start a docker in your workdirectory using:**
```shell
docker run --rm -it \
--name "comp-docker" \
--memory="4g" \
--memory-swap="8g" \
-v "$(pwd)":/your/work/directory/ \
-w /your/work/directory/ \
docker-image-name
```
--name <- The name of the docker, used by the script to find the docker\
--memory <- this sets the amount of memory the docker can use\
--memory-swap <- this is the total of memory and swap (in the example that means up to 4gb of swap can be used)


**Start up the logging script, input parameters are the 2 files for saving.**

**Start your compile in the docker like you would on console.**

# How to Use Multi Log:
**Multilog and sublog need to be in the same folder**
Edit multilog.sh with desired path, build environment and docker.

Run multilog.sh with the parametrs in Configuration or set defaults inside of the file.
