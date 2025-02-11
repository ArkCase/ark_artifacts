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
ARG VER="1.6.4"

ARG HTTPD_VER="1.0.0"
ARG HTTPD_SRC="https://github.com/ArkCase/artifacts-httpd.git"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="8"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

ARG BUILDER_IMAGE="golang"
ARG BUILDER_VER="1.23-alpine3.21"
ARG BUILDER_IMG="${BUILDER_IMAGE}:${BUILDER_VER}"

FROM "${BUILDER_IMG}" AS builder

ARG HTTPD_VER
ARG HTTPD_SRC
ARG HTTPD_SRCPATH="/build/artifacts-httpd"

RUN apk --no-cache add git
RUN mkdir -p "${HTTPD_SRCPATH}" && \
    git clone "${HTTPD_SRC}" "${HTTPD_SRCPATH}" && \
    cd "${HTTPD_SRCPATH}" && \
    git checkout "${HTTPD_VER}" && \
    GO111MODULE=on \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -a -ldflags "-X 'main.AppVersion=v${HTTPD_VER}' -extldflags '-static'" -o /artifacts-httpd

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
COPY --chown=root:root --from=builder /artifacts-httpd /usr/local/bin
COPY --chown=root:root "httpuploader.ini" "${UPLOADER_CFG}"
COPY --chown=root:root scripts/ /usr/local/bin
RUN chmod a+rx /usr/local/bin/* && chmod a=r "${UPLOADER_CFG}"
ENV RENDER_LOCK="${FILE_DIR}/.render-lock"

ENV ARKCASE_DIR="${FILE_DIR}/arkcase"
ENV ARKCASE_CONF_DIR="${ARKCASE_DIR}/conf"
ENV ARKCASE_EXTS_DIR="${ARKCASE_DIR}/exts"
ENV ARKCASE_WARS_DIR="${ARKCASE_DIR}/wars"

ENV PENTAHO_DIR="${FILE_DIR}/pentaho"
ENV PENTAHO_ANALYTICAL_DIR="${PENTAHO_DIR}/analytical"
ENV PENTAHO_REPORTS_DIR="${PENTAHO_DIR}/reports"

ENV SOLR_DIR="${FILE_DIR}/solr"
ENV SOLR_CONFIG_DIR="${SOLR_DIR}/configs"
ENV SOLR_COLLECTIONS_DIR="${SOLR_DIR}/collections"

#
# TODO: More artifacts for deployment here ... maybe even for
# Alfresco initialization and the like
#

#
# Make sure the base tree is created properly
#
RUN for n in \
        "${ARKCASE_DIR}" \
        "${ARKCASE_CONF_DIR}" \
        "${ARKCASE_WARS_DIR}" \
        "${ARKCASE_EXTS_DIR}" \
        "${PENTAHO_DIR}" \
        "${PENTAHO_ANALYTICAL_DIR}" \
        "${PENTAHO_REPORTS_DIR}" \
        "${SOLR_DIR}" \
        "${SOLR_CONFIG_DIR}" \
        "${SOLR_COLLECTIONS_DIR}" \
    ; do mkdir -p "${n}" ; done

USER root
WORKDIR "${FILE_DIR}"
ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
