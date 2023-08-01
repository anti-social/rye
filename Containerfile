FROM docker.io/library/ubuntu:mantic

ARG RYE_EXE_PATH=target/x86_64-unknown-linux-gnu/debug/rye

RUN apt-get update -y && \
    apt-get install -y \
      bats \
      bats-assert \
      ca-certificates && \
    apt-get clean -y

ENV RYE_HOME=/opt/rye
RUN --mount=type=bind,source=${RYE_EXE_PATH},target=/tmp/rye \
    /tmp/rye self install --yes
ENV PATH="${RYE_HOME}/shims:${PATH}"
