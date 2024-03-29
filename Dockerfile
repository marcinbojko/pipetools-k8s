FROM alpine:3.19.0 AS build
ENV KUBE_VERSION=v1.26.12
ENV HELM_VERSION=v3.13.3
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
ENV TZ=Europe/Warsaw
LABEL version="v0.31.30"
LABEL release="pipetools-k8s"
LABEL maintainer="marcinbojko"
SHELL ["/bin/ash", "-euo", "pipefail", "-c"]
# shellcheck disable=SC2169
# shellcheck disable=SC3036
RUN apk add --no-cache --update -t deps \
  ca-certificates curl bash gettext tar gzip openssl gnupg openssh rsync python3 python3-dev py3-pip py3-wheel tzdata yamllint dos2unix jmespath \
  && apk update \
  && apk upgrade --no-cache \
  && curl -fsL https://storage.googleapis.com/kubernetes-release/release/${KUBE_VERSION}/bin/linux/amd64/kubectl -o /bin/kubectl && chmod +x /bin/kubectl \
  && curl -sfL https://get.helm.sh/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64 && chmod +x /bin/helm \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh
CMD ["bash"]
