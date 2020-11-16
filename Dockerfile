FROM oracle/graalvm-ce:20.2.0-java11 as builder

WORKDIR /app
COPY . /app

# BEGIN PRE-REQUISITES FOR STATIC NATIVE IMAGES FOR GRAAL 20.2.0
# SEE: https://github.com/oracle/graal/blob/master/substratevm/StaticImages.md
ARG RESULT_LIB="/staticlibs"

RUN mkdir ${RESULT_LIB} && \
    curl -L -o musl.tar.gz https://musl.libc.org/releases/musl-1.2.1.tar.gz && \
    mkdir musl && tar -xvzf musl.tar.gz -C musl --strip-components 1 && cd musl && \
    ./configure --disable-shared --prefix=${RESULT_LIB} && \
    make && make install && \
    cd / && rm -rf /muscl && rm -f /musl.tar.gz && \
    cp /usr/lib/gcc/x86_64-redhat-linux/4.8.2/libstdc++.a ${RESULT_LIB}/lib/

ENV PATH="$PATH:${RESULT_LIB}/bin"
ENV CC="musl-gcc"

RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.11.tar.gz && \
    mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && cd zlib && \
    ./configure --static --prefix=${RESULT_LIB} && \
    make --silent && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz
#END PRE-REQUISITES FOR STATIC NATIVE IMAGES FOR GRAAL 20.2.0

RUN gu install native-image && \
    curl -O https://download.clojure.org/install/linux-install-1.10.1.727.sh && \
    sh ./linux-install-1.10.1.727.sh && \
    clojure -M:native-image

FROM scratch

COPY --from=builder /app/list-files /list-files

ENTRYPOINT ["/list-files"]