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
ARG BASE_TAG="8.7.0"
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.1.0"

FROM "${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_TAG}"

#
# Basic Parameters
#
ARG ARCH
ARG OS
ARG VER
ARG BASE_DIR="/app"
ARG FILE_DIR="${BASE_DIR}/file"
ARG INIT_DIR="${BASE_DIR}/init"
ARG CONF_DIR="${BASE_DIR}/conf"
ARG DEPL_DIR="${BASE_DIR}/depl"
ARG WAR_DIR="${BASE_DIR}/war"

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="ArkCase Configuration" \
      VERSION="${VER}"

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
    CONF_DIR="${CONF_DIR}" \
    VER="${VER}"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

#################
# Build Arkcase
#################
ENV PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

RUN yum -y update && \
    yum -y install \
        epel-release && \
    yum -y install \
        java-11-openjdk-devel \
        openssl \
        python3-pip \
        unzip \
        wget \
        zip \
    && \
    yum -y clean all && \
    pip3 install openpyxl && \
    rm -rf /tmp/*

COPY "entrypoint" "/"
COPY "fixExcel" "realm-fix" "/usr/local/bin/"
RUN chmod -Rv a+rX "/entrypoint" "/usr/local/bin"

WORKDIR "${BASE_DIR}"

ENTRYPOINT [ "/entrypoint" ]
