FROM itoacr.azurecr.io/ito/sp-certs:0.6 AS certs
FROM alpine:3.13.2 AS build
ENV KUBE_LATEST_VERSION=v1.19.8
ENV HELM_VERSION=v3.5.3
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz
ENV TZ=Europe/Warsaw
LABEL VERSION="v0.13.9"
LABEL RELEASE="pipetools-k8s"
LABEL MAINTAINER="marcinbojko"
SHELL ["/bin/ash", "-euo", "pipefail", "-c"]
# shellcheck disable=SC2169
RUN apk add --no-cache --update -t deps ca-certificates curl bash gettext tar gzip openssl gnupg openssh rsync python3 python3-dev py3-pip py3-wheel tzdata \
  && pip3 install --upgrade pip yamllint dos2unix jmespath \
  && curl -fsL https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /bin/kubectl && chmod +x /bin/kubectl \
  && curl -sfL https://get.helm.sh/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64 && chmod +x /bin/helm \
  && mkdir -p ~/.ssh \
  && eval "$(ssh-agent -s)" \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config \
  && chmod -R 700 ~/.ssh
COPY --from=certs /usr/local/share/ca-certificates /usr/local/share/ca-certificates
RUN update-ca-certificates
CMD ["bash"]
