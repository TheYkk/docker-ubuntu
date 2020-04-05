FROM ubuntu:19.10
LABEL maintainer="Kaan Karakaya <ykk@theykk.net>"

ENV DEBIAN_FRONTEND noninteractive
ENV USER ubuntu
ENV HOME /home/$USER

# Create new user for vnc login.
RUN adduser $USER --disabled-password

# Install Ubuntu Unity.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ubuntu-desktop \
        unity-lens-applications \
        gnome-panel \
        metacity \
        nautilus \
        gedit \
        xterm \
        sudo

# Install dependency components.
RUN apt-get install -y \
        supervisor \
        net-tools \
        curl \
        git \
        pwgen \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Download tigerVNC binaries
ADD https://dl.bintray.com/tigervnc/stable/tigervnc-1.10.1.x86_64.tar.gz $HOME/tigervnc/tigervnc.tar.gz
RUN tar xmzf $HOME/tigervnc/tigervnc.tar.gz -C $HOME/tigervnc/ && rm $HOME/tigervnc/tigervnc.tar.gz
RUN cp -R $HOME/tigervnc/tigervnc-1.10.1.x86_64/* / && rm -rf $HOME/tigervnc/

# Clone noVNC.
RUN git clone https://github.com/novnc/noVNC.git $HOME/noVNC
RUN cp $HOME/noVNC/vnc.html $HOME/noVNC/index.html

# Clone websockify for noVNC
RUN git clone https://github.com/kanaka/websockify $HOME/noVNC/utils/websockify


# Copy supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/

# Set xsession of Unity
COPY xsession $HOME/.xsession

# Copy startup script
COPY startup.sh $HOME

EXPOSE 6080 5901 4040
CMD ["/bin/bash", "/home/ubuntu/startup.sh"]
