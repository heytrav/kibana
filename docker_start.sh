#!/bin/bash

SSH_PASSWORD=`perl -MJSON::PP -e 'print decode_json(qx{curl --cacert /etc/ssl/certs/coreos/ca.pem --cert /etc/ssl/certs/coreos/server.crt --key /etc/ssl/certs/coreos/server.key -L $ENV{ETCD_SERVICE}/v2/keys/iwmn/kibana/ssh_password})->{node}->{value};'`

sed -i 's/localhost/'"$ELASTICSEARCH_SERVICE_HOST"'/g' /opt/kibana/config/kibana.yml

if [ -n "$SSH_PASSWORD" ]; then
    echo "Configuring ssh: setting root password to ${SSH_PASSWORD}"
    echo "root:$SSH_PASSWORD" | chpasswd
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    #grep "PermitRootLogin" /etc/ssh/sshd_config
    /usr/sbin/sshd
    # Append Docker environment variables, otherwise they are not accessable to ssh users
    # in any way
    env | grep _ >> /etc/environment
fi

/usr/bin/supervisord
