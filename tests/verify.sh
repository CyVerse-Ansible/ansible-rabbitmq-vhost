#! /bin/bash

set -e

if ! (rabbitmqctl list_vhosts | grep --quiet '/vhost')
then
  printf 'failed to set vhost /vhost\n'
fi


if ! (rabbitmqctl list_permissions -p /vhost \
        | grep --quiet --regexp '^admin[[:space:]]*\^\$[[:space:]]*\^\$[[:space:]]*\^\$')
then
  printf 'failed to set user admin correctly\n'
fi
