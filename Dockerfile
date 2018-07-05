FROM ubuntu:16.04

ENV LANG=C.UTF-8 \
    ERLANG_VER=20.3.6 \
    ELIXIR_VER="v1.6.6"

WORKDIR /tmp/erlang-build

# Install Erlang
RUN \
    echo "deb http://packages.erlang-solutions.com/ubuntu xenial contrib" >> /etc/apt/sources.list && \
    apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc && \
    apt-get update && apt-get install -y \
      esl-erlang=1:${ERLANG_VER} \
      git \
      build-essential \
      curl \
      wget && \
    apt-get clean && rm -rf /tmp/erlang-build

WORKDIR /tmp/elixir-build

# Install Elixir
RUN \
    wget -q https://github.com/elixir-lang/elixir/archive/${ELIXIR_VER}.tar.gz && \
    tar xzf ${ELIXIR_VER}.tar.gz -C ./ --strip-components 1 && \
    make && make install && \
    mix local.hex --force && \
    mix hex.config mirror_url https://hexpm.upyun.com && \
    mix local.rebar --force && \
    rm ${ELIXIR_VER}.tar.gz && \
    rm -rf /tmp/elixir-build

# Install NPM
RUN \
    curl -sL https://deb.nodesource.com/setup_9.x | bash - && \
    apt-get install -y gcc g++ make \
      nodejs && \
    npm install -g cnpm --registry=https://registry.npm.taobao.org

WORKDIR /

CMD ["/bin/sh"]
