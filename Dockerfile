ARG SP_CERTS="itoacr.azurecr.io/ito/sp-certs:0.6"
FROM ${SP_CERTS} AS certs
FROM alpine:3.11.6 AS build
ENV KUBE_LATEST_VERSION=v1.17.6
ENV HELM_VERSION=v3.2.3
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
LABEL VERSION="v0.0.1"
LABEL RELEASE="pipetools-k8s"
LABEL MAINTAINER="marcinbojko"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# shellcheck disable=SC2169
RUN apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl openssh rsync python3 python3-dev py3-pip \
  && pip3 install --upgrade pip yamllint dos2unix jmespath \
  && curl -sL https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /bin/kubectl && chmod +x /bin/kubectl \
  && curl -sL https://get.helm.sh/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64 && chmod +x /bin/helm \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh
COPY --from=certs /usr/local/share/ca-certificates /usr/local/share/ca-certificates
RUN update-ca-certificates
CMD ["bash"]
