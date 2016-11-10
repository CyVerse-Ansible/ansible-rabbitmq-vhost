Role Name
=========
[![Build Status](https://travis-ci.org/CyVerse-Ansible/ansible-rabbitmq-vhost.svg?branch=master)](https://travis-ci.org/CyVerse-Ansible/ansible-rabbitmq-vhost)

This is a role for configuring a vhost on a RabbitMQ broker.

Requirements
------------

It is assumed that a RabbitMQ server is already installed with the management plugin. The RabbitMQ server should be at least version 3.2.

Role Variables
--------------

Variable                    | Required | Default   | Choices         | Comments
--------------------------- | -------- | --------- | --------------- | --------
`rabbitmq_admin_password`   | no       |           |                 | the password used to authenticate `rabbitmq_admin_user`
`rabbitmq_admin_user`       | no       | guest     |                 | a user able to administer the vhost (doesn't need to have permission on it as long as it is also provided in the `rabbitmq_vhost_users` list)
`rabbitmq_host`             | no       | localhost |                 | the host of RabbitMQ broker owning the vhost
`rabbitmq_mgmt_port`        | no       | 15672     |                 | the port used on `rabbitmq_host` to connect to the management plugin
`rabbimtq_node`             | no       | rabbit    |                 | the erlang node of the rabbitmq server being configured
`rabbitmq_vhost_exchanges`  | no       | []        |                 | the exchanges to add, modify, or remove from the vhost
`rabbitmq_vhost_name`       | yes      |           |                 | the name of the vhost to manage
`rabbitmq_vhost_parameters` | no       | []        |                 | the parameters to add, modify, or remove from the vhost
`rabbitmq_vhost_policies`   | no       | []        |                 | the policies to add or remove from the vhost
`rabbitmq_vhost_queues`     | no       | []        |                 | the queues to add, modify, or remove from the vhost
`rabbitmq_vhost_state`      | no       | present   | absent, present | whether or not the vhost should be present on the server being configured
`rabbitmq_vhost_tracing`    | no       | false     |                 | whether or not tracing should be enabled for this vhost
`rabbitmq_vhost_users`      | no       | []        |                 | the users to add, modify, or remove from the vhost


`irods_vhost_parameters` item 

Field       | Required | Default | Choices         | Comments
----------- | -------- | ------- | --------------- | --------
`component` | yes      |         |                 | component where the parameter is to be set
`name`      | yes      |         |                 | name of parameter
`state`     | no       | present | absent, present | whether or not this parameter should be present on the component
`value`     | no       |         |                 | the value of the parameter as JSON

`irods_vhost_policies` item

Field      | Required | Default | Choices                | Comment
---------- | -------- | ------- | ---------------------- | -------
`apply_to` | no       | all     | all, exchanges, queues | what the policy applies to
`name`     | yes      |         |                        | the name of the policy
`pattern`  | yes      |         |                        | a regular expression used to match the names of what this policy applies to
`priority` | no       |         |                        | the priority of the policy
`state`    | no       | present | absent, present        | whether or not this policy should be present
`tags`     | yes      |         |                        | a dictionary describing the policy

`irods_vhost_users` item

Field            | Required | Default | Choices         | Comment
---------------- | -------- | ------- | --------------- | -------
`configure_priv` | no       | ^$      |                 | regular expression used to restrict the user's configure ability
`name`           | yes      |         |                 | the name of the user
`read_priv`      | no       | ^$      |                 | regular expression used to restrict the user's read ability
`write_priv`     | no       | ^$      |                 | regular expression used to restrict the user's write ability


`irods_vhost_exchanges` item

Field         | Required | Default | Choices                        | Comment
------------- | -------- | ------- | ------------------------------ | -------
`arguments`   | no       |         |                                | a dictionary of extra arguments for the exchange
`auto_delete` | no       |         |                                | a boolean indicating if this exchange is to delete itself once nothing is bound to it
`bindings`    | no       | []      |                                | a list of binding descriptions for the exchanges this exchange is bound to (don't need to exist as long as they are defined in `irods_vhost_exchanges`)
`durable`     | no       | true    |                                | whether or not this exchange is durable
`internal`    | no       |         |                                | a boolean indicating if this exchange is only available for other exchanges
`name`        | yes      |         |                                | the name of the exchange
`state`       | no       | present | absent, present                | whether or not this exchange should be present
`type`        | no       | direct  | direct, fanout, headers, topic | the type of exchange

`irods_vhost_queues` item

Field                     | Required | Default  | Choices         | Comment
------------------------- | -------- | -------- | --------------- | -------
`arguments`               | no       |          |                 | a dictionary of extra arguments for the queue
`auto_delete`             | no       |          |                 | a boolean indicating if this queue should delete itself when nothing is connected to it
`auto_expires`            | no       | forever  |                 | how long (in milliseconds) this queue can be unused before it deletes itself
`bindings`                | no       | []       |                 | a list of binding descriptions for the exchanges this queue is bound to (don't need to exist as long as they are defined in `irods_vhost_exchanges`)
`dead_letter_exchange`    | no       | null     |                 | the name of an exchange where messages will be republished if they expire or are rejected (doesn't need to exist as long as it is defined in `irods_vhost_exchanges`)
`dead_letter_routing_key` | no       | null     |                 | the replacement routing key to use when a message is republished to the `dead_letter_exchange` exchange
`durable`                 | no       | true     |                 | whether or not the queue is durable
`max_length`              | no       | no limit |                 | how many messages this queue can contain before it start rejecting them
`message_ttl`             | no       | forever  |                 | how long (in milliseconds) a message can live in this queue before it is discarded
`name`                    | yes      |          |                 | the name of the queue
`state`                   | no       | present  | absent, present | whether or not this queue should be present

`bindings` item

Field         | Required | Default | Choices         | Comment
------------- | -------- | ------- | --------------- | -------
`arguments`   | no       |         |                 | a dictionary of extra arguments for the binding description
`routing_key` | no       | #       |                 | the routing key
`source`      | yes      |         |                 | the source for the binding
`state`       | no       | present | absent, present | whether or not this binding should be present

Dependencies
------------

* requests >= 1.0.0

Example Playbook
----------------

Here's an example playbook that configures a vhost `/prod/data-store` with three users, an exchange, and two queues. The two queues are bound to the exchange.

```yaml
- hosts: amqp_brokers
  roles:
    - role: cyverse.rabbitmq_vhost
      rabbitmq_admin_user: admin
      rabbitmq_vhost_name: /prod/data-store
      rabbitmq_vhost_users:
        - name: admin
          configure_priv: .*
          write_priv: .*
          read_priv: .*
        - name: irods
          write_priv: .*
        - name: de
          read_priv: .*
      rabbitmq_vhost_exchanges:
        - name: irods
          type: topic
      rabbitmq_vhost_queues:
        - name: indexing
          bindings:
            - source: irods
              routing_key: 'collection.#'
            - source: irods
              routing_key: 'data-object.#'
        - name: type-detection
          bindings:
            - source: irods
              routing_key: data-object.add
```

License
-------

BSD

Author Information
------------------

Tony Edgin
