#! /bin/bash

rabbitmqctl list_vhosts | grep --quiet '/vhost'
