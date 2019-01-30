#!/bin/bash

set -e


update_deployment_package () {
    PACKAGE_DIR="deployment"
    PACKAGE_NAME="lambda.zip"
    PACKAGE_PATH="$PACKAGE_DIR/$PACKAGE_NAME"


    if [ ! -d $PACKAGE_DIR ]; then
        echo "deployment directory not found"
        echo "creating  $PACKAGE_DIR directory..."
        mkdir $PACKAGE_DIR
    fi

    if [ -f $PACKAGE_PATH ]; then
        echo "lambda zip found"
        echo "cleaning up $PACKAGE_PATH ..."
        rm -f $PACKAGE_PATH
    fi

    cp app/target/x86_64-unknown-linux-musl/release/manudped-rss-trans ./bootstrap
    zip $PACKAGE_PATH bootstrap
    rm -f bootstrap
    aws s3 cp $PACKAGE_PATH "s3://manudped-rss-lambda-deployment/$PACKAGE_NAME"
}

apply_infra () {
    echo "applying infrastructure..."
    cd infrastructure
    terraform apply -auto-approve
}


# pipeline

update_deployment_package
apply_infra
