#!/bin/bash

# Make libjpeg from source in the tar subdirectory
# Syntax:
#   make-libpng.sh ${INPUT_TAR} ${OUTPUT_DIR}

CLEAN=0
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UNARCHIVE=${DERIVED_SOURCES_DIR}
TARZ=${1}
BUILD=${2}
VERSION=`basename ${TARZ} | sed 's/\.tar\.gz//'`

# Check for the TAR file to make sure it exists
if [ "${TARZ}XX" == "XX" ] || [ ! -e ${TARZ} ]
then
	echo "Syntax error: make-libpng.sh {INPUT_TAR_GZ} {OUTPUT_FOLDER}"
	exit 1
fi

# Check for the BUILD directory
if [ "${BUILD}XX" == "XX" ] || [ ! -d ${BUILD} ]
then
    echo "Syntax error: make-libpng.sh {INPUT_TAR_GZ} {OUTPUT_FOLDER}"
    exit 1
fi

# Check for the UNARCHIVE  directories, use TMP if necessary
if [ "${UNARCHIVE}XX" == "XX" ]
then
	UNARCHIVE=${TMPDIR}/${VERSION}/src
fi
if [ ! -d ${UNARCHIVE} ]
then
	echo "mkdir ${UNARCHIVE}"
	mkdir -pv ${UNARCHIVE}
fi

##############################################################

PREFIX=${BUILD}/${VERSION}

if [ -e ${PREFIX} ] && [ ${CLEAN} == 0 ]
then
  echo "Assuming already exists: ${PREFIX}"
  exit 0
fi

echo "Unarchiving sources to ${UNARCHIVE}"
echo "Built libpng with be installed at ${PREFIX}"

# remove existing build directory, unarchive
rm -fr "${UNARCHIVE}"
mkdir "${UNARCHIVE}"
tar -C ${UNARCHIVE} -zxvf ${TARZ}

# configure - for 10.6, we only support 64-bit architecture
cd "${UNARCHIVE}/${VERSION}"
export CFLAGS="-arch x86_64"
export LDFLAGS="-arch x86_64"
./configure --prefix="${PREFIX}"

# make and install
make
make install

# make symbolic link
rm -f ${BUILD}/libpng-current
ln -s ${PREFIX} ${BUILD}/libpng-current
exit 0

