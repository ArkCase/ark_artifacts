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
ARG ARCH="amd64"
ARG OS="linux"
ARG VER="1.4.2"

ARG BASE_REPO="arkcase/base"
ARG BASE_VER="8"
ARG BASE_IMG="${PUBLIC_REGISTRY}/${BASE_REPO}:${BASE_VER}"

FROM "${BASE_IMG}"

#
# Basic Parameters
#
ARG ARCH
ARG OS
ARG VER
ARG BASE_DIR="/app"
ARG FILE_DIR="${BASE_DIR}/file"
ARG INIT_DIR="${BASE_DIR}/init"
ARG DEPL_DIR="${BASE_DIR}/depl"

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
    VER="${VER}"

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
COPY --chown=root:root "httpuploader.ini" "${UPLOADER_CFG}"
COPY --chown=root:root scripts/ /usr/local/bin
RUN chmod a+rx /usr/local/bin/* && chmod a=r "${UPLOADER_CFG}"

USER root
WORKDIR "${FILE_DIR}"
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
