docker run \
    --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -d -it \
    -u $(id -u):$(id -g) -e HOME=$HOME -e USER=$USER \
    -v $HOME:$HOME \
    -v /home/$USER/workspace:/home/$USER/workspace \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -w /home/$USER \
    opencv-cudnn
