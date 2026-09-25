#!/bin/sh
set -eu

: "${SATELLITE_URL:?SATELLITE_URL must be set}"
: "${SATELLITE_ORG:?SATELLITE_ORG must be set}"
: "${SATELLITE_ACTIVATIONKEY:?SATELLITE_ACTIVATIONKEY must be set}"

rm -rf /etc/yum.repos.d/*
dnf clean all
subscription-manager clean
curl -k -L --fail "https://${SATELLITE_URL}/pub/katello-server-ca.crt" \
  -o "/etc/pki/ca-trust/source/anchors/${SATELLITE_URL}.ca.crt"
update-ca-trust
rpm -Uhv "https://${SATELLITE_URL}/pub/katello-ca-consumer-latest.noarch.rpm"
subscription-manager register --org="${SATELLITE_ORG}" --activationkey="${SATELLITE_ACTIVATIONKEY}"
dnf repolist --enabled
dnf list --available httpd > /dev/null
