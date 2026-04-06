# CompileLogging

## Only works if compiling with ninja!


# How to use:
Create a Docker Image from the docker file:
```shell
  docker build -t Docker-Image-Name
```
*(This command is deprecated, and maybe removed in the future)*


**Start a docker in your workdirectory using:**
```shell
docker run --rm -it \
--name "comp-docker"\
--memory="4g" \
--memory-swap="8g"\
-v "$(pwd)":/your/work/directory/\
-w /your/work/directory/\
Docker-Image-Name
```
--name <- The name of the docker, used by the script to find the docker\
--memory <- this sets the amount of memory the docker can use\
--memory-swap <- this is the total of memory and swap (in the example that means up to 4gb of swap can be used)


**Start up the logging script, input parameters are the 2 files for saving.**

**Start your compile in the docker like you would on console.**
