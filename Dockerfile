FROM rust

LABEL maintainer="Hayath"
LABEL version="1.0"
LABEL description="The Rust In Its Full Glory"

ARG USERNAME
ARG UID
ARG PROJECT_PWD

RUN apt-get update -y
RUN apt-get autoremove -y
RUN apt-get autoclean -y
RUN apt-get remove git -y || rm /usr/bin/git 
RUN apt-get install libudev-dev -y
# Below is optional
#########################################
#RUN apt-get install -y tree
#RUN apt-get install -y postgresql-client-common postgresql-client
RUN rustup update && rustup install stable
#########################################

RUN useradd -ms /bin/bash $USERNAME -u $UID; exit 0
RUN usermod -a -G sudo $USERNAME; exit 0
RUN usermod -a -G users $USERNAME; exit 0
USER $USERNAME
ENV USER=$USERNAME
ENV PATH=$PATH:/home/$USERNAME/.local/bin/

WORKDIR "$PROJECT_PWD"
#########################################
# for wasm-pack
RUN rustup target add x86_64-pc-windows-gnu
#########################################
