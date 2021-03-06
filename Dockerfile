FROM ubuntu:16.04

ENV LANG=C.UTF-8 \
    OTP_VERSION=20.3.8.2 \
    ELIXIR_VERSION="v1.6.6"

# Install Erlang
RUN \
    apt-get update && apt-get install -y \
      curl \
      build-essential \
      libncurses5-dev \
      openssl \
      libssl-dev \
      fop \
      xsltproc \
      unixodbc-dev \
      autoconf && \
    OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" && \
    runtimeDeps='libodbc1 \
	         libsctp1' && \
    buildDeps='unixodbc-dev \
	       libsctp-dev' && \
    apt-get update && \
    apt-get install -y --no-install-recommends $runtimeDeps && \
    apt-get install -y --no-install-recommends $buildDeps && \
    curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" && \
    export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" && \
    mkdir -vp $ERL_TOP && \
    tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 && \
    rm otp-src.tar.gz && \
    ( cd $ERL_TOP && \
	  ./otp_build autoconf && \
	  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
	  ./configure --build="$gnuArch" \
            --without-javac \
            --without-wx \
            --without-debugger \
            --without-observer \
            --without-jinterface \
            --without-cosEvent\
            --without-cosEventDomain \
            --without-cosFileTransfer \
            --without-cosNotification \
            --without-cosProperty \
            --without-cosTime \
            --without-cosTransactions \
            --without-et \
            --without-gs \
            --without-ic \
            --without-megaco \
            --without-orber \
            --without-percept \
            --without-typer \
            --enable-threads \
            --enable-shared-zlib \
            --enable-ssl=dynamic-ssl-lib \
            --enable-hipe && \
	  make -j$(nproc) && \
	  make install ) && \
	find /usr/local -name examples | xargs rm -rf && \
	apt-get purge -y --auto-remove $buildDeps && \
    rm -rf $ERL_TOP /var/lib/apt/lists/* && \
    # Update ca certificates
    update-ca-certificates --fresh

WORKDIR /tmp/elixir-build

# Install Elixir
RUN \
    ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" && \
    curl -fSL -o ${ELIXIR_VERSION}.tar.gz "$ELIXIR_DOWNLOAD_URL" && \
    tar xzf ${ELIXIR_VERSION}.tar.gz -C ./ --strip-components 1 && \
    make && make install && \
    mix local.hex --force && \
    mix hex.config mirror_url https://hexpm.upyun.com && \
    mix local.rebar --force && \
    rm ${ELIXIR_VERSION}.tar.gz && \
    rm -rf /tmp/elixir-build

# Install NPM
RUN \
    curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    perl -pi -e 's/deb.nodesource.com\/node/mirrors.tuna.tsinghua.edu.cn\/nodesource\/deb/g' /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y gcc g++ make \
      nodejs && \
    npm install -g cnpm --registry=https://registry.npm.taobao.org

WORKDIR /

CMD ["/bin/sh"]
