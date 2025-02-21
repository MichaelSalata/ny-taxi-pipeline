# Use the latest Airflow image (replace with specific version if required)
FROM apache/airflow:2.10.4

# Set the Airflow home directory
ENV AIRFLOW_HOME=/opt/airflow

# Switch to root for package installation
USER root

# Update and install required system packages
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    vim curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies from requirements.txt
COPY requirements.txt .

# Install Google Cloud SDK
ARG CLOUD_SDK_VERSION=480.0.0
ENV GCLOUD_HOME=/opt/google-cloud-sdk
ENV PATH="${GCLOUD_HOME}/bin/:${PATH}"

RUN DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz" \
    && TMP_DIR="$(mktemp -d)" \
    && curl -fL "${DOWNLOAD_URL}" --output "${TMP_DIR}/google-cloud-sdk.tar.gz" \
    && mkdir -p "${GCLOUD_HOME}" \
    && tar xzf "${TMP_DIR}/google-cloud-sdk.tar.gz" -C "${GCLOUD_HOME}" --strip-components=1 \
    && "${GCLOUD_HOME}/install.sh" \
       --bash-completion=false \
       --path-update=false \
       --usage-reporting=false \
       --quiet \
    && rm -rf "${TMP_DIR}" \
    && gcloud --version

# Switch to airflow user before installing pip dependencies
USER airflow

RUN pip install --no-cache-dir -r requirements.txt

# Set the working directory
WORKDIR $AIRFLOW_HOME

# Switch back to the airflow user
USER $AIRFLOW_UID
