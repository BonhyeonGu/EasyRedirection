FROM ubuntu:22.04
LABEL email="bonhyeon.gu@9bon.org"
LABEL name="BonhyeonGu"

ENV TZ=Asia/Seoul
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git tzdata python3 python3-pip nano openssh-server supervisor && \
    apt-get clean

RUN echo $TZ > /etc/timezone && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN pip3 install flask

# SSH 설정
RUN echo "PermitRootLogin yes\nPasswordAuthentication yes\nChallengeResponseAuthentication no" >> /etc/ssh/sshd_config && \
    echo "root:root@1234" | chpasswd

# Flask 앱 복제
WORKDIR /root
RUN git clone https://github.com/BonhyeonGu/EasyRedirection p
WORKDIR /root/p/

# Supervisor 설정 생성
RUN echo "[supervisord]\n" \
         "nodaemon=true\n" \
         "\n" \
         "[program:sshd]\n" \
         "command=/usr/sbin/sshd -D\n" \
         "autostart=true\n" \
         "autorestart=true\n" \
         "priority=1\n" \
         "\n" \
         "[program:flask]\n" \
         "command=python3 /root/p/app.py\n" \
         "autostart=true\n" \
         "autorestart=true\n" \
         "priority=2\n" > /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 5000

# Supervisor로 SSH 및 Flask 실행
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]