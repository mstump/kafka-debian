#!/bin/bash

VERSION=$1
REVISION=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="kafka_$VERSION-$REVISION"
KAFKA_DIR="$BUILD_DIR/opt/kafka"
TARFILE="kafka-$VERSION-incubating-src.tgz"
CONTROL_FILE="$BUILD_DIR/DEBIAN/control"
URL="http://mirrors.ibiblio.org/apache/incubator/kafka/kafka-$VERSION-incubating/$TARFILE"


function help {
    echo ""
    echo -e '\e[1;37;44mAn Ubuntu/Debian packaging script for Apache Kafka\033[0m'
    echo ""
    echo "USAGE: $0 VERSION REVISION"
    echo ""
    echo "$0 0.7.2 1"
    echo ""
    echo "VERSION: the Kafka release version (eg: 0.7.2)"
    echo "REVISION: the revision number to use when generating the .deb (eg: 1)"
    echo ""
}


if [ -z "$VERSION" ] || [ "${VERSION}xxx" = "xxx" ]
then 
    help
    exit 1
fi

if [ -z "$REVISION" ] || [ "${REVISION}xxx" = "xxx" ]
then 
    help
    exit 1
fi


cd $DIR

if [ ! -f "$BUILD_DIR" ]
then
    cp -rp template $BUILD_DIR
fi

if [ ! -f "$TARFILE" ]
then
    wget -O $TARFILE $URL
fi

if [ -f "$KAFKA_DIR" ]
then
    rm -rf $KAFKA_DIR
fi

if [ -f "$BUILD_DIR.deb" ]
then
    rm "$BUILD_DIR.deb"
fi

mkdir -p $KAFKA_DIR
tar -zxf $TARFILE --strip 1 -C $KAFKA_DIR

cd $KAFKA_DIR
./sbt update
./sbt package

cd $DIR
sed -i "s/\$VERSION/$VERSION/g" $CONTROL_FILE
sed -i "s/\$REVISION/$REVISION/g" $CONTROL_FILE
dpkg-deb --build $BUILD_DIR

