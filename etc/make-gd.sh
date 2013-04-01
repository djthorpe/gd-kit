#!/bin/bash

# Make gd from source in the tar subdirectory
# Syntax:
#   make-gd.sh ${INPUT_TAR} ${OUTPUT_DIR}

CLEAN=0
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UNARCHIVE=${DERIVED_SOURCES_DIR}
TARZ=${1}
BUILD=${2}
VERSION=`basename ${TARZ} | sed 's/\.tar\.gz//' | sed 's/gd-//'`

# Check for the TAR file to make sure it exists
if [ "${TARZ}XX" == "XX" ] || [ ! -e ${TARZ} ]
then
	echo "Syntax error: make-gd.sh {INPUT_TAR_GZ} {OUTPUT_FOLDER}"
	exit 1
fi

# Check for the BUILD directory
if [ "${BUILD}XX" == "XX" ] || [ ! -d ${BUILD} ]
then
    echo "Syntax error: make-gd.sh {INPUT_TAR_GZ} {OUTPUT_FOLDER}"
    exit 1
fi

# Check for the UNARCHIVE  directories, use TMP if necessary
if [ "${UNARCHIVE}XX" == "XX" ]
then
	UNARCHIVE=${TMPDIR}/gd-${VERSION}/src
fi
if [ ! -d ${UNARCHIVE} ]
then
	echo "mkdir ${UNARCHIVE}"
	mkdir -pv ${UNARCHIVE}
fi

##############################################################

FLAGS_FREETYPE="--with-freetype=/tmp/freetype-current"
FLAGS_LIBJPEG="--with-jpeg=/tmp/libjpeg-current"
FLAGS_LIBPNG="--with-png=/tmp/libpng-current"

##############################################################

PREFIX=${BUILD}/gd-${VERSION}

if [ -e ${PREFIX} ] && [ ${CLEAN} == 0 ]
then
  echo "Assuming already exists: ${PREFIX}"
  exit 0
fi

echo "Version = ${VERSION}"
echo "Unarchiving sources to ${UNARCHIVE}"
echo "Built gd with be installed at ${PREFIX}"

# remove existing build directory, unarchive
rm -fr "${UNARCHIVE}"
mkdir "${UNARCHIVE}"
tar -C ${UNARCHIVE} -zxvf ${TARZ}

# configure - for 10.6, we only support 64-bit architecture
cd "${UNARCHIVE}/gd/${VERSION}"
export CFLAGS="-arch x86_64"
export LDFLAGS="-arch x86_64"
./configure --prefix="${PREFIX}" --enable-shared=yes --enable-static=no \
	${FLAGS_FREETYPE} ${FLAGS_LIBJPEG} ${FLAGS_LIBPNG}

# make and install
make
make install

# make symbolic link
rm -f ${BUILD}/gd-current
ln -s ${PREFIX} ${BUILD}/gd-current
echo "Build in ${BUILD}/gd-current"
exit 0
