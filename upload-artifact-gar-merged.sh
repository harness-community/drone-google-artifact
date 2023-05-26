#!/bin/bash

GOOGLE_APPLICATION_CREDENTIALS=$PLUGIN_GOOGLE_APPLICATION_CREDENTIALS
REPOSITORY=$PLUGIN_REPOSITORY
LOCATION=$PLUGIN_LOCATION
SERVICE_ACCOUNT_EMAIL=$PLUGIN_SERVICE_ACCOUNT_EMAIL
PROJECT_ID=$PLUGIN_PROJECT_ID
FORMAT=$PLUGIN_FORMAT
FILE=$PLUGIN_FILE
PYTHON_VERSION=$PLUGIN_PYTHON_VERSION
DIST_PATH=$PLUGIN_DIST_PATH
IMAGE=$PLUGIN_IMAGE
DOCKERFILE_PATH=$PLUGIN_DOCKERFILE_PATH

# Authenticate to Google Cloud
gcloud config set artifacts/repository $REPOSITORY
gcloud config set artifacts/location $LOCATION
gcloud config set account $SERVICE_ACCOUNT_EMAIL

gcloud auth activate-service-account $SERVICE_ACCOUNT_EMAIL --key-file=$GOOGLE_APPLICATION_CREDENTIALS --project=$PROJECT_ID

if [ "$FORMAT" = "apt" ]; then
    # Upload APT artifact
    gcloud artifacts apt upload $REPOSITORY --source=$FILE

elif [ "$FORMAT" = "yum" ]; then
    # Upload APT artifact
    gcloud artifacts apt upload $REPOSITORY --source=$FILE

elif [ "$FORMAT" = "python" ]; then

    # Set up Python
    pip install --upgrade pip
    pip install setuptools
    pip install wheel
    pip install twine
    pip install keyrings.google-artifactregistry-auth

    # Build the package
    python setup.py sdist

    # Upload Python package to Artifact Registry
    gcloud artifacts print-settings python > ~/.pypirc
    twine upload --repository $REPOSITORY $DIST_PATH/*

elif [ "$FORMAT" = "maven" ]; then
    mvn deploy

elif [ "$FORMAT" = "image" ]; then

    # Log in to Google Artifact Registry
    cat $GOOGLE_APPLICATION_CREDENTIALS | docker login -u _json_key --password-stdin https://$LOCATION-docker.pkg.dev

    # Build the container image
    docker build -t $IMAGE -f $DOCKERFILE_PATH .

    # Tag and push the container image
    docker tag $IMAGE $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE
    docker push $LOCATION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE

    echo "Container image uploaded successfully!"

else
    echo "Invalid FORMAT provided."
    exit 1
fi

echo "Upload complete."
