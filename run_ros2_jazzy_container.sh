#!/bin/sh
echo "Run ROS2 Jazzy Base Container"

# Not needed for docker on WSL2, as WSL handles GUI applications natively.
# xhost + local:root

# Mount the .X11.unix driver to be able to open GUI applications.
# Allow GPU passthrough to get hardware acceleration
docker run \
    --name ros2_jazzy  \
    --gpus all \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --privileged \
    -it \
    --ipc host \
    --rm \
    ros2_base:jazzy