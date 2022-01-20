#!/bin/bash

set -e # Abort on error.

cp -r ${BUILD_PREFIX}/share/libtool/build-aux/config.* .

# recommended in https://gitter.im/conda-forge/conda-forge.github.io?at=5c40da7f95e17b45256960ce
find ${PREFIX}/lib -name '*.la' -delete

# Force python bindings to not be built.
unset PYTHON

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# See https://github.com/AnacondaRecipes/aggregate/pull/103
if [[ $target_platform =~ linux.* ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
  mkdir -p ${PREFIX}/include/linux
  cp ${RECIPE_DIR}/userfaultfd.h ${PREFIX}/include/linux/userfaultfd.h
fi

# `--without-pam` was removed.
# See https://github.com/conda-forge/gdal-feedstock/pull/47 for the discussion.

bash configure --prefix=${PREFIX} \
               --host=${HOST} \
               --with-curl \
               --with-dods-root=${PREFIX} \
               --with-expat=${PREFIX} \
               --with-freexl=${PREFIX} \
               --with-geos=${PREFIX}/bin/geos-config \
               --with-geotiff=${PREFIX} \
               --with-hdf4=${PREFIX} \
               --with-cfitsio=${PREFIX} \
               --with-hdf5=${PREFIX} \
               --with-tiledb=${PREFIX} \
               --with-jpeg=${PREFIX} \
               --with-kea=${PREFIX}/bin/kea-config \
               --with-libiconv-prefix=${PREFIX} \
               --with-libjson-c=${PREFIX} \
               --with-libkml=${PREFIX} \
               --with-liblzma=yes \
               --with-libtiff=${PREFIX} \
               --with-libz=${PREFIX} \
               --with-netcdf=${PREFIX} \
               --with-openjpeg=${PREFIX} \
               --with-pcre \
               --with-pg=yes \
               --with-png=${PREFIX} \
               --with-poppler=${PREFIX} \
               --with-spatialite=${PREFIX} \
               --with-sqlite3=${PREFIX} \
               --with-proj=${PREFIX} \
               --with-webp=${PREFIX} \
               --with-xerces=${PREFIX} \
               --with-xml2=yes \
               --without-python \
               --verbose \
               ${OPTS}

make -j $CPU_COUNT ${VERBOSE_AT}

if [[ $target_platform =~ linux.* ]]; then
  rm ${PREFIX}/include/linux/userfaultfd.h
fi

make install

# Make sure GDAL_DATA and set and still present in the package.
# https://github.com/conda/conda-recipes/pull/267
ACTIVATE_DIR=${PREFIX}/etc/conda/activate.d
DEACTIVATE_DIR=${PREFIX}/etc/conda/deactivate.d
mkdir -p ${ACTIVATE_DIR}
mkdir -p ${DEACTIVATE_DIR}

cp ${RECIPE_DIR}/scripts/activate.sh ${ACTIVATE_DIR}/gdal-activate.sh
cp ${RECIPE_DIR}/scripts/deactivate.sh ${DEACTIVATE_DIR}/gdal-deactivate.sh
