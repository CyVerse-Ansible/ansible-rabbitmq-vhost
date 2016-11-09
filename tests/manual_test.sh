#! /bin/bash

readonly distribution=centos
readonly version=6
readonly ROLE_DIR=/etc/ansible/roles/CyVerse-Ansible.rabbitmq-vhost
readonly TEST_DIR="$ROLE_DIR"/tests


# Start the container
docker run --detach --interactive --tty --name=test_dummy --volume="$PWD"/..:"$ROLE_DIR":rw \
           cyverse/ansible-test:latest-"$distribution"-"$version" bash

if [ "$?" -ne 0 ]
then
  exit 1
fi


# Install required software
if [ "$?" -eq 0 ]
then
  docker exec test_dummy "$TEST_DIR"/bootstrap.sh
fi
  
# Check syntax of role
if [ "$?" -eq 0 ]
then
  docker exec test_dummy \
    ansible-playbook --syntax-check --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/test.yml
fi

# Run configuration test
if [ "$?" -eq 0 ]
then
  docker exec test_dummy \
    ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/test.yml
fi

# Verify configuration
if [ "$?" -eq 0 ]
then
  docker exec test_dummy "$TEST_DIR"/verify.sh
fi

# Idempotentence test
if [ "$?" -eq 0 ]
then
  docker exec test_dummy \
        ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory \
                         "$TEST_DIR"/test.yml \
    | grep --quiet --regexp='changed=0.*failed=0' \
      && echo 'Idempotence test: pass' \
      || echo 'Idempotence test: fail'
fi

docker stop test_dummy
docker rm test_dummy
