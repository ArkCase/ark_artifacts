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
ARG VER="1.6.5"

ARG BASE_REGISTRY="${PUBLIC_REGISTRY}"
ARG BASE_REPO="arkcase/base"
ARG BASE_VER="22.04"
ARG BASE_VER_PFX=""
ARG BASE_IMG="${BASE_REGISTRY}/${BASE_REPO}:${BASE_VER_PFX}${BASE_VER}"

ARG HTTPD_REGISTRY="${BASE_REGISTRY}"
ARG HTTPD_REPO="arkcase/artifacts-httpd"
ARG HTTPD_VER="latest"
ARG HTTPD_VER_PFX="${BASE_VER_PFX}"
ARG HTTPD_IMAGE="${HTTPD_REGISTRY}/${HTTPD_REPO}:${HTTPD_VER_PFX}${HTTPD_VER}"

FROM "${HTTPD_IMAGE}" AS httpd

FROM "${BASE_IMG}"

#
# Basic Parameters
#
ARG ARCH
ARG OS
ARG VER

LABEL ORG="ArkCase LLC" \
      MAINTAINER="Armedia Devops Team <devops@armedia.com>" \
      APP="ArkCase Configuration" \
      VERSION="${VER}"

#
# Environment variables
#
ENV VER="${VER}"
ENV FILE_DIR="${BASE_DIR}/file"
ENV INIT_DIR="${BASE_DIR}/init"
ENV DEPL_DIR="${BASE_DIR}/depl"

#
# Add the script that allows us to add files
#
COPY --chown=root:root --chmod=0755 --from=httpd /artifacts-httpd /usr/local/bin
COPY --chown=root:root --chmod=0755 entrypoint /
COPY --chown=root:root --chmod=0755 scripts/* /usr/local/bin

ENV RENDER_LOCK="${FILE_DIR}/.render-lock"
ENV ARTIFACTS_MANIFEST="${FILE_DIR}/.artifacts.yaml"

ENV ARKCASE_DIR="${FILE_DIR}/arkcase"
ENV ARKCASE_CONF_DIR="${ARKCASE_DIR}/conf"
ENV ARKCASE_EXTS_DIR="${ARKCASE_DIR}/exts"
ENV ARKCASE_WARS_DIR="${ARKCASE_DIR}/wars"

ENV PENTAHO_DIR="${FILE_DIR}/pentaho"
ENV PENTAHO_ANALYTICAL_DIR="${PENTAHO_DIR}/analytical"
ENV PENTAHO_REPORTS_DIR="${PENTAHO_DIR}/reports"
ENV PENTAHO_RESOURCE_BUNDLES_DIR="${PENTAHO_DIR}/resource-bundles"

ENV SOLR_DIR="${FILE_DIR}/solr"
ENV SOLR_CONFIG_DIR="${SOLR_DIR}/configs"
ENV SOLR_COLLECTIONS_DIR="${SOLR_DIR}/collections"

#
# TODO: More artifacts for deployment here ... maybe even for
# Alfresco initialization and the like
#

#
# Make sure the base tree is created properly. Non-existent
# directories can lead to unexpected errors
#
RUN for n in \
        "${ARKCASE_DIR}" \
        "${ARKCASE_CONF_DIR}" \
        "${ARKCASE_WARS_DIR}" \
        "${ARKCASE_EXTS_DIR}" \
        "${PENTAHO_DIR}" \
        "${PENTAHO_ANALYTICAL_DIR}" \
        "${PENTAHO_REPORTS_DIR}" \
        "${PENTAHO_RESOURCE_BUNDLES_DIR}" \
        "${SOLR_DIR}" \
        "${SOLR_CONFIG_DIR}" \
        "${SOLR_COLLECTIONS_DIR}" \
    ; do mkdir -p "${n}" ; done

USER root
WORKDIR "${FILE_DIR}"
ENTRYPOINT [ "/entrypoint" ]
