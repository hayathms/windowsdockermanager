#!/bin/bash

#cp docker/DevDockerFile Dockerfile;

# Setting env sp database may pick the names

# Take user input to ask weather they want to build using docker or podman
echo "Enter 1 for docker and 2 for podman"
read -p "Enter your choice: " choice

# if user selects docker than EXE_CMD_TOOL should be set to docker , if user selects 2 than it should be set to $EXE_CMD_TOOL

if [ $choice -eq 1 ]
then
    EXE_CMD_TOOL="docker"
elif [ $choice -eq 2 ]
then
    EXE_CMD_TOOL="podman"
else
    echo "Invalid choice"
    exit 1
fi

export NETWORK_NAME=$NETWORK_NAME

# Check if the network name is empty
if [ -z "$NETWORK_NAME" ]; then
  echo "Warning: Network name is empty"
  exit 1
fi

# Check if the network exists
if $EXE_CMD_TOOL network inspect "$NETWORK_NAME" &>/dev/null; then
  echo "Network '$NETWORK_NAME' already exists"
else
  echo "Creating network '$NETWORK_NAME'"
  $EXE_CMD_TOOL network create "$NETWORK_NAME"
fi

CONTAINER=$($EXE_CMD_TOOL ps| grep $SERVICE_NAME)
echo $CONTINER

if [ ${#CONTAINER} -ge 5 ]; then
    echo "Continer is already running";
    echo "Entering Continer ........";
    $EXE_CMD_TOOL exec -it $SERVICE_NAME /bin/bash;
    exit 1;
else
    echo "Continer not running";
fi

IMAGE=$($EXE_CMD_TOOL images| grep $SERVICE_IMAGE)

if [ ${#IMAGE} -ge 5 ]; then
    echo "Image Exists";
else
    echo "Build New Image";
    $EXE_CMD_TOOL build --build-arg USERNAME="${USER}" --build-arg UID="${UID}" --build-arg PROJECT_PWD="${PROJECT_PWD}" -t "${SERVICE_IMAGE}:latest" .;
fi

CMD="$EXE_CMD_TOOL run --userns=host --hostname $SERVICE_NAME -it --network $NETWORK_NAME --name $SERVICE_NAME $PORT_ADDRESS $ADDITIONAL_VOLUMES -v ${PROJECT_PWD}/../:${PROJECT_PWD}/../:z \"${SERVICE_IMAGE}:latest\" /bin/bash";

echo $CMD

echo "";
echo "********************";
echo "********************";
echo " Test Build will run ";
echo "********************";

eval $CMD

TAG_NUMBER=$($EXE_CMD_TOOL ps -a|grep $SERVICE_NAME|awk '{ print $1}');
$EXE_CMD_TOOL commit $TAG_NUMBER $SERVICE_IMAGE:latest;
$EXE_CMD_TOOL rm $TAG_NUMBER;

echo "----------------"
echo "If Quiting happened peacefully than all data is saved to image";
echo "----------------"
