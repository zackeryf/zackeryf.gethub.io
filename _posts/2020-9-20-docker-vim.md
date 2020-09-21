---
layout: post
title: docker-vim
---

Wouldn't it be nice to have your development environment up and running in a few simple commands? Well that is what I have attemted to create with [docker-vim][docker-vim]. Every developer has their favorite setup customized for themselves. But this customization makes it so that you cant just sit down at a new computer or vm and start hacking away.

The idea here is a developer could create a docker container with all of their customizations and simply run the container on virtually any environment that has docker installed. That means that a developer would have to invest time upfront to set up the container, but could save time in the future.

I was able to create a container that ran vim with some minimal customizations, nothing too fancy, just a pretty status line and the NERDTree plugin as a proof of concept. You can see what I came up with in my github [repo][docker-vim].

But one thing that is missing from projects like these is the process that someone took to create the product. While I was building this I tried to take note of the process that I did to create docker-vim. Maybe this can help people realize that things dont just get created in one fell swoop, which if you read tutorials is the impression that I get.

## Deliverable
* Container with vim installed and configured.
* Able to run container and edit a file that can be accessed outside the container.
* Able to run container and run graphical vim.

## Development Process
First build a container based on ubuntu.

Logged on to docker hub and looked up the official ubuntu project

Create a Dockerfile with FROM ubuntu:18.04

Went to vim page and cloned the git repo but I was able to get a apt install in the container to work.

To get the vim install to work first I had to do a apt-get update, then a apt-get -y install vim. You need to do the update so it can find vim, you need the -y so that it will automatically install vim

Looked at the vimplug documentation to see how to install that. It just curls a file. curl is not installed by default so I had to install that and then call the curl command.

I had to install git because vimplug relies on that to clone the plugins to install.

I copied my .vimrc into the container using the COPY command.

Now that the vimrc is in the container we need to install the plugins. This was done by running vim and using options that will execute PlugInstall and exit. This is done with the command vim --not-a-term -c "PlugInstall" -c "qa".

I installed and set the locale to utf-8, one of the plugins complained about it.

I also had to set an environment variable to ENV TERM=xterm-256color so that the terminal will have colors.

I also set the environment variable ENV DISPLAY=:0, this is needed if we want to use the graphical environment. Allthough it is not working yet.

I also added an ENTRYPOINT, this is needed to make the container behave like a executable.

At this point I have a minimal working container that will start vim.

Next we need to create a directory in the container that can be mapped to directories to the host running the container, so that documents can be persisted. The mount point is created in the dockerfile using the VOLUME directive.

I had to rework the WORKDIR to the new documents directory so that when vim is started by the container it will operate there.

To mount a host directory to the container, when executing the docker command you must specify the --mount option and use type=bind the src= option is the directory on the host that will be used and the dst= option is the directory in the container.

To clean up things I removed the bash-syntax plugin and removed the install of locale utf-8 because it was not needed.

I added a simple Makefile so that I can build the container easily.

## To build
`docker build --build-arg user_name="$(id --user --name)" --build-arg user_id="$(id --user)" -t docker-vim:latest .`

## To Run
`docker container run -it --mount type=bind,source="$(pwd)",destination="${HOME}/documents" docker-vim:latest $@`

## Wrapper script to easily start
This will be a simple script that will start the docker container, hopefully as close to the same way one might start it locally.

The first iteration of the script script should take as option the file name that vim will operate in and ultimately save the files to. The container will map the current working directory from the host to the container.

## Saving files as a user
Here is [an article on how to run a container as the current user](https://jtreminio.com/blog/running-docker-containers-as-current-host-user/)

I will attempt the simple way of doing things by just passing in the userID and groupID on the command line. I think most development files will be owned by the current user and group. If needed we can do the more complicated way described in the article. By passing in the userid when starting the container, the container is actually running with those userid's. The thing is the user in the docker container is incomplete, it does not have a name associated with it. So if you exec into the container you will see the string "I have no name" and it does not have a home directory. I think there are two ways to solve this. I know vim can be configured to save the .swp files to a different directory than the one that it is operating in. I if I did this, saving the files to a directory in the container, when it exits the swp files will go away. But since this is running as a non root user where would I save them? I could create another docker volume specifically for the swp files, but that seems silly. Unfortunately it would be guaranteed that you would lose the swp file if something bad would happen.

Using the simple way works where the files are owned by the user but it has a annoying side effect. It is not cleaning up the .swp files on exit, so when you open vim again you get the swap warning.

So I think I will attempt to add a user to the docker container using the same userid as the user that executed the docker container and see if that cleans up the swp files.
Creating the user and getting everything installed to a user in the container with the same user id and group id proved to be pretty difficult.
When everything was running as root everything installed to /root correctly. When using the new user I had to make sure that I installed the pluging manager and copied the vimrc to /home/${user_name}. Before I didn't have to specify the full path. I had to add ARG's to the dockerfile for the user_name and user_id, these values are now passed in via the docker build command using the --build-arg option. This does mean that the user will have to build the container on their user account so that it will properly create the user in the container. I did provide a make file that will execute the proper build command. There may be a way to get docker compose to do this too.

## Future
Try to make it use a gui:

<http://wiki.ros.org/docker/Tutorials/GUI>

[docker-vim]: https://github.com/zackeryf/docker-vim