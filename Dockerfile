FROM chenjr0719/ubuntu-unity-novnc
ENV USER skateboard \
    HOME /home/skateboard
USER 0
RUN apt-get -y update \
    && apt-get -y install apt-utils
RUN apt-get install -y build-essential cpio qemu aqemu wget zip git bc \ 
    libncurses-dev perl libmodule-install-perl nano default-jdk \
    && adduser --disabled-password --gecos "" skateboard \
    && cd /home/skateboard \
    && mkdir scripts \
    && mkdir patches
COPY scripts/* /home/skateboard/scripts/
COPY patches/* /home/skateboard/patches/
RUN cd /home/skateboard \
    && chown -R skateboard:skateboard * \
    && chmod 755 scripts/*
USER skateboard
WORKDIR /home/skateboard
RUN /bin/bash scripts/update-build-environment
EXPOSE 5901
EXPOSE 6901
SHELL ["/bin/bash"]
