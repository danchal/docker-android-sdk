FROM ubuntu:22.04

LABEL de.mindrunner.android-docker.flavour="ubuntu-standalone"

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

ENV DEBIAN_FRONTEND noninteractive

# Install required tools
# Dependencies to execute Android builds

RUN dpkg --add-architecture i386
#RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
#  libc6:i386 \
#  libgcc1:i386 \
#  libncurses5:i386 \
#  libstdc++6:i386 \
#  zlib1g:i386 \
RUN apt-get update -yqq
RUN apt-get install -y \
  curl \
  expect \
  git \
  make \
  openjdk-17-jdk \
  wget \
  unzip \
  vim \
  openssh-client \
  locales \
  libarchive-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android -u 1000 android

COPY tools /opt/tools

COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

# extra
RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
 libc6:i386 \
 libgcc1:i386 \
 libncurses5:i386 \
 libstdc++6:i386 \
 zlib1g:i386 \
 wget unzip vim python3 g++ \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/34.0.0"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN sdkmanager "platforms;android-28"
RUN sdkmanager "system-images;android-28;default;x86_64"
RUN sdkmanager 'cmake;3.22.1'
RUN sdkmanager 'ndk;26.1.10909125'

ENV PATH "${ANDROID_HOME}/ndk/26.1.10909125/prebuilt/linux-x86_64/bin:${PATH}"

CMD /opt/tools/entrypoint.sh built-in
