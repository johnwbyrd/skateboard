# See instructions at:
# https://github.com/ConSol/docker-headless-vnc-container
# for running this docker image.
FROM consol/centos-xfce-vnc
# n.b. This is a mirror
ENV BUILDROOT_GIT=https://github.com/buildroot/buildroot.git 
USER 0
RUN yum install -y qemu wget zip git bc ncurses-devel perl-devel \
    && yum -y groupinstall "Development Tools" \
    && useradd -ms /bin/bash skateboard
USER skateboard
WORKDIR /home/skateboard
RUN git clone $BUILDROOT_GIT \
    && cd buildroot \
    && make qemu_arm_versatile_nommu_defconfig \
    && make
EXPOSE 5901
EXPOSE 6901
RUN echo "To connect to this container, you can:" \
    && echo "1. connect via VNC viewer localhost:5901" \
    && echo "   default password: vncpassword" \
    && echo "2. connect via noVNC HTML5 full client: " \
    && echo "   http://localhost:6901/vnc.html, default password: vncpassword" \
    && echo "3. connect via noVNC HTML5 lite client: " \
    && echo "   http://localhost:6901/?password=vncpassword"
SHELL ["/bin/bash"]
