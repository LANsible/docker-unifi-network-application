#!/bin/sh

export MONGO_URI="mongodb://$MONGO_USER:$MONGO_PASS@$MONGO_HOST:${MONGO_PORT:-27017}/$MONGO_DBNAME?tls=${MONGO_TLS:-false}\&authSource=${MONGO_AUTHSOURCE:-admin}"
export MONGO_STAT_URI="mongodb://$MONGO_USER:$MONGO_PASS@$MONGO_HOST:${MONGO_PORT:-27017}/${MONGO_DBNAME}_stat?tls=${MONGO_TLS:-false}\&authSource=${MONGO_AUTHSOURCE:-admin}"

# setup properties file when not existing (can't overwrite each time since unifi writes to this file at runtime)
if [ ! -f "/data/system.properties" ]; then
    envsubst < /usr/lib/unifi/system.properties.tpl > /data/system.properties
else
    sed -ie 's/^db.mongo.uri=.*/db.mongo.uri='"$MONGO_URI"'/g' /data/system.properties
    sed -ie 's/^statdb.mongo.uri=.*/statdb.mongo.uri='"$MONGO_STAT_URI"'/g' /data/system.properties
    sed -ie 's/^unifi.db.name=.*/unifi.db.name='"$MONGO_DBNAME"'/g' /data/system.properties
fi

# Import the additional certificate into JVM truststore
if [ -f "/certificates/tls.crt" ]; then
    echo "importing certificates into Unify keystore"
    openssl pkcs12 -export -passout pass:unifi -in /certificates/tls.crt -inkey /certificates/tls.key -out /dev/shm/keystore.p12 -name unifi
    if [ -f "/data/keystore" ]; then
        keytool -delete -storepass aircontrolenterprise -alias unifi -keystore /data/keystore
    fi
    keytool -importkeystore \
        -deststorepass aircontrolenterprise \
        -destkeypass aircontrolenterprise \
        -destkeystore /data/keystore \
        -srckeystore /dev/shm/keystore.p12 \
        -srcstoretype PKCS12 \
        -srcstorepass unifi
    rm -rf /dev/shm/keystore.p12
fi

exec "$@"