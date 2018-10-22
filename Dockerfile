FROM ubuntu:18.04
USER 0
COPY scripts/install-prerequisites /root/install-prerequisites
RUN bash -c /root/install-prerequisites
COPY scripts/* /home/skateboard/scripts/
COPY patches/* /home/skateboard/patches/
RUN cd /home/skateboard \
    && chown -R skateboard:skateboard * \
    && chmod 755 scripts/*
USER skateboard
WORKDIR /home/skateboard
RUN bash -c scripts/update-build-environment
EXPOSE 5901
EXPOSE 6901
SHELL ["/bin/bash"]
