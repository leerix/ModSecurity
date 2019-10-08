FROM gcc

RUN mkdir -p /modsecurity
COPY . /modsecurity
WORKDIR /modsecurity
RUN ./build.sh
RUN ./configure

RUN make
RUN make install
