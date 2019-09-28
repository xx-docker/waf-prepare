From centos:7

MAINTAINER actanble <actanble@gmail.com>

# Todo: set time and lang-code
ENV LANG en_US.UTF-8
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
RUN sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
RUN curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
RUN yum makecache

# todo: All Libs Used Backup In https://github.com/offgithub On 2019-5-28
ENV TENGINE_VERSION=2.3.0
ENV DEPLOY_PATH=/usr/local/src/nginx_waf

RUN mkdir -p ${DEPLOY_PATH}
#VOLUME ${DEPLOY_PATH}
WORKDIR ${DEPLOY_PATH}

# Install yum-libs Deppends
RUN yum -y install wget curl git supervisor
RUN yum install autoconf automake bzip2 \
         flex httpd-devel libaio-devel \
         libass-devel libjpeg-turbo-devel libpng12-devel \
         libtheora-devel libtool libva-devel libvdpau-devel \
         libvorbis-devel libxml2-devel libxslt-devel \
         perl texi2html unzip zip openssl \
         openssl-devel geoip geoip-devel gcc-c++ \
         gd-devel GeoIP GeoIP-devel GeoIP-data libxml2 libxml2-dev zlib-devel \
         perl perl-devel perl-ExtUtils-Embed redhat-rpm-config -y

# Todo: Install gperftools
RUN git clone https://github.com/gperftools/gperftools && cd gperftools && sh autogen.sh && ./configure && make && make install

# Install Luajit2
RUN git clone https://github.com/openresty/luajit2 && cd luajit2 &&  make && make install

# Download Tengine
RUN wget https://github.com/alibaba/tengine/archive/${TENGINE_VERSION}.zip  && unzip ${TENGINE_VERSION}.zip -d ${DEPLOY_PATH}

# Todo: nginx-with-mosecurity
# https://github.com/SpiderLabs/ModSecurity/wiki/Compilation-recipes-for-v3.x#centos-7-minimal-dynamic
RUN git clone https://github.com/SpiderLabs/ModSecurity-nginx.git ;

# Download The crs-3.0.1 Rules
RUN wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.1.0.zip && unzip v3.1.0.zip -d /opt/ && \
mv /opt/owasp-modsecurity-crs-3.1.0 /opt/owasp-modsecurity-crs

RUN git clone https://github.com/SpiderLabs/ModSecurity.git \
        &&  cd ModSecurity  \
        &&  /bin/bash build.sh  \
        && yum install -y https://archives.fedoraproject.org/pub/archive/fedora/linux/updates/23/x86_64/b/bison-3.0.4-3.fc23.x86_64.rpm \
        &&  git submodule init  \
        &&  git submodule update  \
        &&  ./configure \
        && make && make install
