docker build \
    --build-arg USERNAME=$USER \
    --build-arg USER_UID=$(id -u) \
    --build-arg USER_GID=$(id -g) \
    -t opencv-cudnn .
