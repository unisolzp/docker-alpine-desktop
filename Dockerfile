# Set base image
# https://github.com/jlesage/docker-baseimage-gui
FROM jlesage/baseimage-gui:alpine-3.12-glibc

# Define software versions.
# Alpine version
ARG ALPINE_VERSION=3.12
# https://github.com/avih/dejsonlz4 -- commit id is version
ARG JSONLZ4_VERSION=c4305b8
# https://github.com/lz4/lz4/releases -- tag is version
ARG LZ4_VERSION=1.8.1.2

# Define software download URLs.
ARG JSONLZ4_URL=https://github.com/avih/dejsonlz4/archive/${JSONLZ4_VERSION}.tar.gz
ARG LZ4_URL=https://github.com/lz4/lz4/archive/v${LZ4_VERSION}.tar.gz

# Define working directory.
WORKDIR /tmp

# Add Repos permanently
RUN \
	echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Upgrade current packages
RUN \
	apk --update --no-cache upgrade

# Generate and install favicons.
RUN \
	APP_ICON_URL=https://github.com/xfce-mirror/xfdesktop/raw/master/pixmaps/xfce4_xicon1.png \
	&& install_app_icon.sh "$APP_ICON_URL"

# Install console packages
RUN \
	apk --no-cache add \
		bash \
		bash-completion \
		bash-doc \
		ca-certificates \
		curl \
		dbus \
		dbus-x11 \
		eudev \
		ffmpeg \
		ffmpeg-libs \
		fuse \
		git \
		htop \
		libgcc \
		libstdc++ \
		mandoc \
		mandoc-apropos \
		mandoc-soelim \
		man-pages \
		mc \
		mesa-dri-swrast \
		nss \
		p7zip \
		p7zip-doc \
		python3 \
		py3-pip \
		py3-qt5 \
		qt5-qtbase \
		qt5-qtsvg \
		rsync \
		rtmpdump \
		screen \
		sudo \
		tar \
		tar-doc \
		tmux \
		unrar \
		unzip \
		util-linux \
		vim \
		wget \
		wxgtk \
		xz \
		xz-doc \
		zip \
	&& update-ca-certificates

# TODO
# Install pip / pipsi

# Install XFCE4
RUN \
	apk --no-cache add \
		desktop-file-utils \
		exo \
		garcon \
		gtk+2.0 \
		libxfce4ui \
		libxfce4util \
		thunar \
		thunar-archive-plugin \
		ttf-dejavu \
		ttf-freefont \
		xarchiver \
		xdotool \
		xfce4-appfinder \
		xfce4-panel \
		xfce4-settings \
		xfce4-terminal \
		xfconf \
		xfdesktop \
		xterm \
		yad

# Install Flat Icon theme
RUN \
	git clone https://github.com/daniruiz/flat-remix \
	&& mkdir -p /usr/share/icons/ \
	&& rsync -av --progress flat-remix/Flat-Remix-Green-Dark /usr/share/icons/ \
	&& gtk-update-icon-cache /usr/share/icons/Flat-Remix-Green-Dark/ \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

# Install PRO Dark XFCE theme
RUN \
	git clone https://github.com/paullinuxthemer/PRO-Dark-XFCE-Edition.git \
	&& mkdir -p /usr/share/themes/ \
	&& rsync -av --progress 'PRO-Dark-XFCE-Edition/PRO-dark-XFCE-edition II' /usr/share/themes/ \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

# Install X Pakcages
RUN \
	apk --no-cache add \
		chromium 
# Add files.
COPY rootfs/ /

# Add home dir for "app" user
# Add "app" user to sudoers file
RUN \
	ln -s /config/home/app /home/app \
	&& echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set environment variables
ENV APP_NAME="xfce4" \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	TERM=xfce4-terminal \
	SHELL=/bin/bash

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Expose ports.
#   - 3129: For MyJDownloader in Direct Connection mode.
EXPOSE 3129

# Metadata.
LABEL \
	org.label-schema.name="xfce4" \
	org.label-schema.description="Docker container for XFCE4 desktop with openbox as window manager" \
	org.label-schema.version="unknown" \
	org.label-schema.vcs-url="https://github.com/shokinn/docker-alpine-desktop" \
	org.label-schema.schema-version="1.0" \
	maintainer="Philip Henning <mail@philip-henning.com>"
