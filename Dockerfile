FROM ubuntu:bionic

RUN ./build.sh
RUN ./configure

RUN make
RUN make install
