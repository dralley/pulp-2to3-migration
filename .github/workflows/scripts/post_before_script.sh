#!/usr/bin/env bash

set -euv

sudo sed -i  "s/bindIp: 127.0.0.1/bindIp: 127.0.0.1,$(ip address show dev docker0 | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")/g" /etc/mongod.conf
sudo systemctl restart mongod

# install mongo and copy a script which we need to use for func tests to roll out a pulp 2 snapshot
cmd_prefix bash -c "cat > /etc/yum.repos.d/mongodb-org-3.6.repo <<EOF
[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/8Server/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
EOF"

cmd_prefix bash -c "dnf install -y mongodb-org-tools mongodb-org-shell"
cat pulp_2to3_migration/tests/functional/scripts/set_pulp2.sh | cmd_stdin_prefix bash -c "cat > /tmp/set_pulp2.sh"
cmd_prefix bash -c "chmod 755 /tmp/set_pulp2.sh"
