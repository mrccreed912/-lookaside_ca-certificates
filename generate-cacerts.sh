#!/bin/bash
# source: https://github.com/hgomez/obuildfactory/blob/master/openjdk7/linux/build.sh

set -e
set -x

p11-kit extract --comment --format=openssl-bundle --filter=certificates --overwrite ca-bundle.trust.crt
cat ca-bundle.trust.crt | awk '/-----BEGIN TRUSTED CERTIFICATE-----/,/-----END TRUSTED CERTIFICATE-----/{ print $0; }' > cacert-clean.pem
# split  -p "-----BEGIN CERTIFICATE-----" cacert-clean.pem cert_
csplit -k -f cert_ cacert-clean.pem "/-----BEGIN TRUSTED CERTIFICATE-----/" {*}
rm cert_00
rm cacert-clean.pem
rm -f cacerts

for CERT_FILE in `ls -v cert_*`; do
    ALIAS=$(basename ${CERT_FILE})
    openssl x509 -in ${CERT_FILE} -inform pem -outform der -out ${CERT_FILE}.der
    echo yes | keytool -import -alias ${ALIAS} -keystore cacerts -storepass 'changeit' -file ${CERT_FILE}.der || :
    rm -f $CERT_FILE
    rm -f ${CERT_FILE}.der
done

