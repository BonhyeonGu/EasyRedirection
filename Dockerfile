FROM ubuntu:22.04
LABEL email="bonhyeon.gu@9bon.org"
LABEL name="BonhyeonGu"

ENV TZ=Asia/Seoul
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git tzdata python3 python3-pip nano openssh-server && \
    apt-get clean

RUN echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN pip3 install flask

RUN echo "PermitRootLogin yes\nPasswordAuthentication yes\nChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "root:root@1234" | chpasswd

WORKDIR /root
RUN git clone https://github.com/BonhyeonGu/EasyRedirection p
WORKDIR /root/p/
CMD service ssh start && python3 app.py &