FROM ubuntu:18.04

#########################
# Install prerequisites #
#########################

RUN \
  apt-get update && \
  apt-get install -y ca-certificates curl git

########################
# Install WASI SDK 8.0 #
########################

RUN curl -L https://github.com/CraneStation/wasi-sdk/releases/download/wasi-sdk-8/wasi-sdk-8.0-linux.tar.gz | tar xz --strip-components=1 -C /

#####################
# Build actual code #
#####################

WORKDIR /code

RUN git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git && cd libjpeg-turbo && git checkout 2.0.0

COPY include include
COPY jconfig.h libjpeg-turbo/jconfig.h
COPY jconfigint.h libjpeg-turbo/jconfigint.h

# Relase build
RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Iinclude/ -Ilibjpeg-turbo/ -Oz     -o jpeg-turbo.wasm -DWITH_SIMD=0 -nostartfiles -fvisibility=hidden -Wl,--no-entry,--demangle,--allow-undefined,--export=malloc,--export=free,--export=tjInitDecompress,--export=tjDecompressHeader3,--export=tjDecompress2,--export=tjDestroy,--strip-all -- libjpeg-turbo/jcapimin.c libjpeg-turbo/jcapistd.c libjpeg-turbo/jccoefct.c libjpeg-turbo/jccolor.c libjpeg-turbo/jcdctmgr.c libjpeg-turbo/jchuff.c libjpeg-turbo/jcicc.c libjpeg-turbo/jcinit.c libjpeg-turbo/jcmainct.c libjpeg-turbo/jcmarker.c libjpeg-turbo/jcmaster.c libjpeg-turbo/jcomapi.c libjpeg-turbo/jcparam.c libjpeg-turbo/jcphuff.c libjpeg-turbo/jcprepct.c libjpeg-turbo/jcsample.c libjpeg-turbo/jctrans.c libjpeg-turbo/jdapimin.c libjpeg-turbo/jdapistd.c libjpeg-turbo/jdatadst.c libjpeg-turbo/jdatasrc.c libjpeg-turbo/jdcoefct.c libjpeg-turbo/jdcolor.c libjpeg-turbo/jddctmgr.c libjpeg-turbo/jdhuff.c libjpeg-turbo/jdicc.c libjpeg-turbo/jdinput.c libjpeg-turbo/jdmainct.c libjpeg-turbo/jdmarker.c libjpeg-turbo/jdmaster.c libjpeg-turbo/jdmerge.c libjpeg-turbo/jdphuff.c libjpeg-turbo/jdpostct.c libjpeg-turbo/jdsample.c libjpeg-turbo/jdtrans.c libjpeg-turbo/jerror.c libjpeg-turbo/jfdctflt.c libjpeg-turbo/jfdctfst.c libjpeg-turbo/jfdctint.c libjpeg-turbo/jidctflt.c libjpeg-turbo/jidctfst.c libjpeg-turbo/jidctint.c libjpeg-turbo/jidctred.c libjpeg-turbo/jquant1.c libjpeg-turbo/jquant2.c libjpeg-turbo/jutils.c libjpeg-turbo/jmemmgr.c libjpeg-turbo/jmemnobs.c libjpeg-turbo/jsimd_none.c libjpeg-turbo/turbojpeg.c libjpeg-turbo/transupp.c libjpeg-turbo/jdatadst-tj.c libjpeg-turbo/jdatasrc-tj.c libjpeg-turbo/rdbmp.c libjpeg-turbo/rdppm.c libjpeg-turbo/wrbmp.c libjpeg-turbo/wrppm.c

# Debug build
# RUN clang --sysroot=/share/wasi-sysroot --target=wasm32-unknown-wasi -Iinclude/ -Ilibjpeg-turbo/ -O0 -g3 -o jpeg-turbo.wasm -DWITH_SIMD=0 -nostartfiles -fvisibility=hidden -Wl,--no-entry,--demangle,--allow-undefined,--export=malloc,--export=free,--export=tjInitDecompress,--export=tjDecompressHeader3,--export=tjDecompress2,--export=tjDestroy             -- libjpeg-turbo/jcapimin.c libjpeg-turbo/jcapistd.c libjpeg-turbo/jccoefct.c libjpeg-turbo/jccolor.c libjpeg-turbo/jcdctmgr.c libjpeg-turbo/jchuff.c libjpeg-turbo/jcicc.c libjpeg-turbo/jcinit.c libjpeg-turbo/jcmainct.c libjpeg-turbo/jcmarker.c libjpeg-turbo/jcmaster.c libjpeg-turbo/jcomapi.c libjpeg-turbo/jcparam.c libjpeg-turbo/jcphuff.c libjpeg-turbo/jcprepct.c libjpeg-turbo/jcsample.c libjpeg-turbo/jctrans.c libjpeg-turbo/jdapimin.c libjpeg-turbo/jdapistd.c libjpeg-turbo/jdatadst.c libjpeg-turbo/jdatasrc.c libjpeg-turbo/jdcoefct.c libjpeg-turbo/jdcolor.c libjpeg-turbo/jddctmgr.c libjpeg-turbo/jdhuff.c libjpeg-turbo/jdicc.c libjpeg-turbo/jdinput.c libjpeg-turbo/jdmainct.c libjpeg-turbo/jdmarker.c libjpeg-turbo/jdmaster.c libjpeg-turbo/jdmerge.c libjpeg-turbo/jdphuff.c libjpeg-turbo/jdpostct.c libjpeg-turbo/jdsample.c libjpeg-turbo/jdtrans.c libjpeg-turbo/jerror.c libjpeg-turbo/jfdctflt.c libjpeg-turbo/jfdctfst.c libjpeg-turbo/jfdctint.c libjpeg-turbo/jidctflt.c libjpeg-turbo/jidctfst.c libjpeg-turbo/jidctint.c libjpeg-turbo/jidctred.c libjpeg-turbo/jquant1.c libjpeg-turbo/jquant2.c libjpeg-turbo/jutils.c libjpeg-turbo/jmemmgr.c libjpeg-turbo/jmemnobs.c libjpeg-turbo/jsimd_none.c libjpeg-turbo/turbojpeg.c libjpeg-turbo/transupp.c libjpeg-turbo/jdatadst-tj.c libjpeg-turbo/jdatasrc-tj.c libjpeg-turbo/rdbmp.c libjpeg-turbo/rdppm.c libjpeg-turbo/wrbmp.c libjpeg-turbo/wrppm.c

CMD base64 --wrap=0 jpeg-turbo.wasm
