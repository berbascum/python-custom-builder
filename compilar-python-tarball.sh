#!/bin/bash

## Script per a compilar python des de tarball
## Version: 0.0.1

# Upstream-Name: python-custom-prebuilts
# Source: https://github.com/berbascum/python-custom-prebuilts
#
# Copyright (C) 2024 Berbascum <berbascum@ticv.cat>
# All rights reserved.
#
# BSD 3-Clause License
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Variables globals
START_DIR="$(pwd)"


ACCIO=""
[ -n "$(echo $@ | grep "altinstall")" ] \
    && ACCIO="altinstall"
[ -z "${ACCIO}" ] \
    && ACCIO="createdeb"

MAINTAINER_NAME="berbascum"
MAINTAINER_EMAIL="${MAINTAINER_NAME}@ticv.cat"

PYTHON_MAIN_VER="3.9"
PYTHON_SUB_VER="20"
PYTHON_MAIN_FULL_VER="${PYTHON_MAIN_VER}.${PYTHON_SUB_VER}"
PYTHON_DOWNLOAD="https://www.python.org/ftp/python/${PYTHON_MAIN_FULL_VER}/Python-${PYTHON_MAIN_FULL_VER}.tgz"

APT_DEPS="wget curl build-essential libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libgdbm-dev liblzma-dev tk-dev libffi-dev zlib1g-dev libncurses5-dev libnss3-dev"

[ "${ACCIO}" == "createdeb" ] \
    && APT_DEPS_EXTRA="checkinstall"

## Instal·la deps
sudo apt-get update
sudo apt-get install "${APT_DEPS} ${APT_DEPS_EXTRA}" -y 

## Obtenció codi font
if [ ! -e Python-${PYTHON_MAIN_FULL_VER}.tgz ]; then
    echo "Obtenint codi font de python ${PYTHON_MAIN_FULL_VER}..."
    wget -q ${PYTHON_DOWNLOAD}
fi

if [ ! -e Python-${PYTHON_MAIN_FULL_VER} ]; then
    echo "Desempaquetant codi font de python ${PYTHON_MAIN_FULL_VER}..."
    tar zxf Python-${PYTHON_MAIN_FULL_VER}.tgz
fi

cd Python-${PYTHON_MAIN_FULL_VER}

## configure
./configure --enable-optimizations --with-ensurepip=install --enable-shared

## Compilació
make -j 4

if [ "${ACCIO}" == "createdeb" ]; then
    ## Creació deb (Opció 1)
    ## Acció per defecte
    sudo checkinstall \
        --pkgname=python${PYTHON_MAIN_VER} \
        --pkgversion="${PYTHON_MAIN_FULL_VER}" \
        --backup=no \
        --deldoc=yes --nodoc \
        --fstrans=no --install=no \
        --pkggroup="interpreters"  \
        --default
        #--maintainer="${MAINTAINER_NAME} <${MAINTAINER_EMAIL}>" \
elif [ "${ACCIO}" == "altinstall" ]; then
    ## Requereix "altinstall" com a un dels arguments de l'script
    ## make altinstall (Opció 2)
    sudo make altinstall
    sudo ldconfig /usr/local/share/python${PYTHON_MAIN_VER}
    ## Verificàció
    #python3.x --version
fi

echo && echo "Finalitzat!"
