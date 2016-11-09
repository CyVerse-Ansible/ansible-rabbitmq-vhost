#! /bin/bash

yum install --assumeyes python-requests

yum install --assumeyes erlang
yum install --assumeyes \
    https://www.rabbitmq.com/releases/rabbitmq-server/v3.3.1/rabbitmq-server-3.3.1-1.noarch.rpm

rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server start
