ARG ALPINE_BASE_IMAGE_TAG=${ALPINE_BASE_IMAGE_TAG:-latest}
ARG TERRAFORM_VERSION=${TERRAFORM_VERSION:-1.9}
ARG TERRAFORM_MIRROR_FILENAME=${TERRAFORM_MIRROR_FILENAME:-local-mirror.tf}

FROM hashicorp/terraform:${TERRAFORM_VERSION} AS builder

ARG MAINTAINER
ARG TERRAFORM_MIRROR_FILENAME

LABEL maintainer="${MAINTAINER}"

USER root

# create terraform local providers mirror
WORKDIR /tmp
COPY ${TERRAFORM_MIRROR_FILENAME} .
RUN terraform init \
    && rm ${TERRAFORM_MIRROR_FILENAME}

ENTRYPOINT []

# Create custom image with unpacked providers
FROM alpine:${ALPINE_BASE_IMAGE_TAG}

ARG MAINTAINER

LABEL maintainer="${MAINTAINER}"

# Copy Terraform binary and the local mirror structure from the build stage
# COPY --from=builder /bin/terraform /usr/bin/terraform
COPY --from=builder /bin/terraform /terraform/terraform
COPY --from=builder /tmp/.terraform/providers/registry.terraform.io /usr/share/terraform/plugins/registry.terraform.io/