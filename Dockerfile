##############################################################################
##                                 Base Image                               ##
##############################################################################
ARG ROS_DISTRO=jazzy
ARG ROS_PKG=desktop-full-noble
FROM osrf/ros:jazzy-desktop-full-noble
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Delete initial user fropm Ubuntu 24.04, if not deleted the existing non-root user
# breaks the uid and gid assignment taking place in "build_image.sh"
RUN deluser ubuntu

##############################################################################
##                                 Global Dependecies                       ##
##############################################################################
# UTF-8 Support
ENV LANG C.UTF-8 
ENV LC_ALL C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    software-properties-common \
    dirmngr gnupg2 lsb-release can-utils iproute2\
    apt-utils bash nano aptitude util-linux \
    htop git tmux sudo wget gedit bsdmainutils \
    mesa-utils x11-utils pip && \
    # Mesa Graphics Workaround 
    add-apt-repository ppa:kisak/kisak-mesa -y &&  \
    apt update && \
    apt upgrade -y && \
    # Clear apt-cache to reduce image size
    rm -rf /var/lib/apt/lists/*

##############################################################################
##                                 Create User                              ##
##############################################################################
ARG USER=docker
ARG PASSWORD=docker
ARG UID=1000
ARG GID=1000
ARG DOMAIN_ID=17
ARG VIDEO_GID=44
ENV ROS_DOMAIN_ID=${DOMAIN_ID}
ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}
RUN groupadd -g "$GID" "$USER"  && \
    useradd -m -u "$UID" -g "$GID" --shell $(which bash) "$USER" -G sudo && \
    groupadd realtime && \
    groupmod -g ${VIDEO_GID} video && \
    usermod -aG video "$USER" && \
    usermod -aG dialout "$USER" && \
    usermod -aG realtime "$USER" && \
    echo "$USER:$PASSWORD" | chpasswd && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudogrp
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /etc/bash.bashrc
RUN echo "export ROS_DOMAIN_ID=${DOMAIN_ID}" >> /etc/bash.bashrc

USER $USER  


##############################################################################
##                                 User Dependencies                        ##
##############################################################################
WORKDIR /home/$USER/
CMD /bin/bash

