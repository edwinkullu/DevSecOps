FROM gcr.io/google.com/cloudsdktool/cloud-sdk:latest

ENV HELM_VERSION=v3.14.4
ENV HELMFILE_VERSION=1.4.4
ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True
ENV HELM_PLUGINS=/root/.local/share/helm/plugins

RUN apt-get update && apt-get install -y \
    google-cloud-sdk-gke-gcloud-auth-plugin \
    wget curl tar git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    | tar xz -C /usr/local/bin --strip-components=1 linux-amd64/helm \
    && helm version

RUN wget -qO- https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
    | tar xz -C /usr/local/bin helmfile \
    && helmfile --version

RUN helm plugin install https://github.com/databus23/helm-diff --version v3.9.9 \
    && helm plugin list

ENTRYPOINT ["bash"]