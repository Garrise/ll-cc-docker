FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VNC_PASSWD=vncpasswd
COPY start.sh /root/start.sh
# 添加国内源
# COPY sources.list /etc/apt/sources.list

RUN apt update && apt install -y \
    openbox \
    xorg \
    dbus-user-session \
    openbox \
    curl \
    unzip \
    x11vnc \
    xvfb \
    fluxbox \
    supervisor \
    libnotify4 \
    libnss3 \
    xdg-utils \
    libsecret-1-0 \
    ffmpeg \
    libgbm1 \
    libasound2 \
    fonts-wqy-zenhei \
    git \
    gnutls-bin && \
    apt clean --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 安装NoVnc
RUN git config --global http.sslVerify false && git config --global http.postBuffer 1048576000 && \
    cd /opt && git clone https://github.com/novnc/noVNC.git && \
    cd /opt/noVNC/utils && git clone https://github.com/novnc/websockify.git && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html

# https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240410_amd64_01.deb
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -o /root/linuxqq.deb https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.7_240410_${arch}_01.deb
RUN chmod +x /root/linuxqq.deb && apt install -y /root/linuxqq.deb
RUN rm /root/linuxqq.deb

# 下载LiteLoader
RUN version=$(curl -Ls "https://api.github.com/repos/LiteLoaderQQNT/LiteLoaderQQNT/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -o /tmp/LiteLoaderQQNT.zip https://github.com/LiteLoaderQQNT/LiteLoaderQQNT/releases/download/${version}/LiteLoaderQQNT.zip && \
    mkdir -p /opt/QQ/resources/app/LiteLoader && \
        ##  ---调试开启  检测文件情况 ls /opt/QQ/resources/app/app_launcher/ && \
    # 修补QQ载入LiteLoader
    sed -i "1i\require('/opt/QQ/resources/app/LiteLoader/');" /opt/QQ/resources/app/app_launcher/index.js && \
        ##  ---调试开启 检测修补情况 cat /opt/QQ/resources/app/app_launcher/index.js  && \
    # 下载LLOneBot
    curl -L -o /tmp/LLOneBot.zip https://github.com/LLOneBot/LLOneBot/releases/download/$(curl -Ls "https://api.github.com/repos/LLOneBot/LLOneBot/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/LLOneBot.zip && \
    # 下载LLWebUiApi
    curl -L -o /tmp/LLWebUiApi.zip https://github.com/LLOneBot/LLWebUiApi/releases/download/$(curl -Ls "https://api.github.com/repos/LLOneBot/LLWebUiApi/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/LLWebUiApi.zip
# 下载ChrOnoCat
RUN cc_version=$(curl -Ls "https://api.github.com/repos/chrononeko/chronocat/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -L -o /tmp/chronocat-llqqnt-engine-chronocat-api.zip https://github.com/chrononeko/chronocat/releases/download/${cc_version}/chronocat-llqqnt-engine-chronocat-api-${cc_version}.zip && \
    curl -L -o /tmp/chronocat-llqqnt-engine-chronocat-event.zip https://github.com/chrononeko/chronocat/releases/download/${cc_version}/chronocat-llqqnt-engine-chronocat-event-${cc_version}.zip && \
    curl -L -o /tmp/chronocat-llqqnt-engine-crychiccat.zip https://github.com/chrononeko/chronocat/releases/download/${cc_version}/chronocat-llqqnt-engine-crychiccat-${cc_version}.zip && \
    curl -L -o /tmp/chronocat-llqqnt.zip https://github.com/chrononeko/chronocat/releases/download/${cc_version}/chronocat-llqqnt-${cc_version}.zip && \
    # 自动配置
    \
    mkdir -p ~/.vnc && \
    \
    chmod +x ~/start.sh && \
    \
    echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "[program:qq]" >> /etc/supervisord.conf && \
    echo "command=qq --no-sandbox" >> /etc/supervisord.conf && \
    echo 'environment=DISPLAY=":1"' >> /etc/supervisord.conf
    
VOLUME ["/opt/QQ/resources/app/LiteLoader"]
# 设置容器启动时运行的命令
CMD ["/bin/bash", "-c", "startx & sh /root/start.sh"]
