#!/bin/bash

# use scipy_packages.txt if Makefile create .scipy
[[ -e '/stack/.scipy' ]] && packages_file=scipy_packages.txt || packages_file=packages.txt
echo "using $packages_file to determine packages"

#
# rethinkdb
#
source /etc/lsb-release && echo "deb http://download.rethinkdb.com/apt $DISTRIB_CODENAME main" > /etc/apt/sources.list.d/rethinkdb.list
wget -qO- http://download.rethinkdb.com/apt/pubkey.gpg | apt-key add -

#
# SYSTEM PACKAGES
#
export DEBIAN_FRONTEND=noninteractive
apt-get update
cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.custom
xargs apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew < /stack/${packages_file}
mv /etc/ImageMagick-6/policy.xml.custom /etc/ImageMagick-6/policy.xml
apt-get autoclean autoremove -y

#
# PIL library patch
#

for file in libjpeg.so libfreetype.so libz.so; do
  [[ -f /usr/lib/x86_64-linux-gnu/${file} ]] && ln -s /usr/lib/x86_64-linux-gnu/${file} /usr/lib
done

[[ -d /usr/include/freetype2 ]] && ln -s /usr/include/freetype2 /usr/include/freetype2/freetype

# Create persistent user
userid=32768
username=expauser

addgroup --quiet --gid "$userid" "$username"
adduser \
    --shell /bin/bash \
    --disabled-password \
    --force-badname \
    --no-create-home \
    --uid "$userid" \
    --gid "$userid" \
    --gecos '' \
    --quiet \
    --home /app \
    "$username"
