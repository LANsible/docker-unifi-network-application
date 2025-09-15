# docker-unifi-network-application

Properly without s6 overlay etc etc.

Important note, the UUIDs needs to match in the system.properties when moving an existing install!
If the controller detects a mismatch between the mongo database and the system.properties it will wipe the database.

For a new install just run `uuidgen` and use a static UUID so this will never occur and makes migration easier.