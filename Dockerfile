###########################################################################################################
#
# How to build:
#
# docker build -t arkcase/deploy-base:latest .
#
###########################################################################################################

#
# Basic Parameters
#
ARG PUBLIC_REGISTRY="public.ecr.aws"
ARG BASE_REPO="arkcase/base"
ARG BASE_TAG="8-02"
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.4.0"
ARG BLD="01"
ARG MVN_VER="3.9.4"
ARG MVN_SRC="https://archive.apache.org/dist/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

#
# Basic Parameters
#
ARG ARCH
ARG OS
ARG VER
ARG BLD
ARG BASE_DIR="/app"
ARG FILE_DIR="${BASE_DIR}/file"
ARG INIT_DIR="${BASE_DIR}/init"
ARG DEPL_DIR="${BASE_DIR}/depl"
ARG MVN_SRC

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="ArkCase Configuration" \
      VERSION="${VER}-${BLD}"

#
# Environment variables
#
ENV JAVA_HOME="/usr/lib/jvm/java" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US:en" \
    LC_ALL="en_US.UTF-8" \
    BASE_DIR="${BASE_DIR}" \ 
    FILE_DIR="${FILE_DIR}" \
    INIT_DIR="${INIT_DIR}" \
    VER="${VER}" \
    MVN_HOME="/mvn"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

#################
# Prepare the base environment
#################
ENV PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

#
# We add all of this crap b/c it may come in handy later and it doesn't
# weigh enough to be of true concern
#
RUN yum -y install \
        epel-release && \
    yum -y install \
        java-11-openjdk-devel \
        git \
        jq \
        openssl \
        patch \
        python3-pip \
        unzip \
        wget \
        xmlstarlet \
        zip \
    && \
    yum -y clean all && \
    pip3 install openpyxl && \
    rm -rf /tmp/*

#
# Add the script that allows us to add files
#
ARG UPLOADER_CFG="/app/httpuploader.ini"
ENV UPLOADER_CFG="${UPLOADER_CFG}"
COPY "httpuploader.ini" "${UPLOADER_CFG}"
COPY \
    "entrypoint" \
    "httpuploader.py" \
    "mvn-get" \
    "mvn-crypt" \
    "prep-artifact" \
    "render-helpers" \
    "rebuild-helpers" \
    "/usr/local/bin/"
RUN chmod a+rx \
        "/usr/local/bin/entrypoint" \
        "/usr/local/bin/mvn-get" \
        "/usr/local/bin/mvn-crypt" \
        "/usr/local/bin/prep-artifact" \
        "/usr/local/bin/httpuploader.py" \
        "/usr/local/bin/render-helpers" \
    && \
    chmod a=r "${UPLOADER_CFG}"

#
# Install Maven
#
RUN mkdir -p "${MVN_HOME}" && \
    curl -kL "${MVN_SRC}" | tar -C "${MVN_HOME}" --strip-components=1 -xzvf - && \
    chmod -R a+rX "${MVN_HOME}"

# Add Maven to the path
ENV PATH="${MVN_HOME}/bin:${PATH}"

USER root
WORKDIR "${FILE_DIR}"
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
