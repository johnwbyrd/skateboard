FROM consol/centos-xfce-vnc
ENV USER skateboard \
    HOME /home/skateboard
USER 0
RUN yum -y upgrade \
    && yum -y groupinstall "Development Tools" \
    && yum install -y qemu wget zip git bc ncurses-devel perl-devel \
       java-1.8.0-openjdk nano \
    && useradd -ms /bin/bash skateboard
RUN cd /home/skateboard \
    && mkdir scripts \
    && mkdir patches
COPY scripts/* /home/skateboard/scripts/
COPY patches/* /home/skateboard/patches/
RUN cd /home/skateboard \
    && chown -R skateboard:skateboard * \
    && chmod 755 scripts/*
USER skateboard
WORKDIR /home/skateboard
EXPOSE 5901
EXPOSE 6901
SHELL ["/bin/bash"]
