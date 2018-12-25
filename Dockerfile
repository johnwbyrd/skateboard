FROM ubuntu:18.04
USER 0
COPY scripts/install-prerequisites /root/install-prerequisites
RUN chmod 755 /root/install-prerequisites \
    && bash -c /root/install-prerequisites
RUN useradd -ms /bin/bash skateboard
COPY CMakeLists.txt /home/skateboard/CMakeLists.txt
COPY config /home/skateboard/config/
COPY scripts /home/skateboard/scripts/
RUN cd /home/skateboard \
    && chown -R skateboard:skateboard * \
    && chmod 755 scripts/*
USER skateboard
WORKDIR /home/skateboard
RUN mkdir build \
    && cd build \
    && cmake .. \
    && make
SHELL ["/bin/bash"]
