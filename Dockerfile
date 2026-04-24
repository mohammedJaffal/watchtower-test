FROM ubuntu:22.04

ARG WATCHTOWER_TEST_USER=test
ARG WATCHTOWER_TEST_PASSWORD=change-me

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo procps iproute2 iputils-ping net-tools && \
    mkdir /var/run/sshd && \
    useradd -m -s /bin/bash "${WATCHTOWER_TEST_USER}" && \
    echo "${WATCHTOWER_TEST_USER}:${WATCHTOWER_TEST_PASSWORD}" | chpasswd && \
    mkdir -p "/home/${WATCHTOWER_TEST_USER}/.ssh" && \
    chown -R "${WATCHTOWER_TEST_USER}:${WATCHTOWER_TEST_USER}" "/home/${WATCHTOWER_TEST_USER}/.ssh" && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
