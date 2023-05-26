FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    python3 \
    python3-pip \
    default-jdk \
    maven \
    docker.io

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-sdk

ADD upload-artifact-gar-merged.sh /bin/

ENTRYPOINT ["/usr/bin/bash", "-l", "-c", "/bin/upload-artifact-gar-merged.sh"]
