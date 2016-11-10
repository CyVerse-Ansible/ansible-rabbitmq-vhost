#! /bin/bash

readonly distribution=centos
readonly version=6
readonly ROLE_DIR=/etc/ansible/roles/CyVerse-Ansible.rabbitmq-vhost
readonly TEST_DIR="$ROLE_DIR"/tests


# Start the container
printf 'Starting docker container\n'
docker run --detach --interactive --tty --name=test_dummy --volume="$PWD"/..:"$ROLE_DIR":rw \
           cyverse/ansible-test:latest-"$distribution"-"$version" bash \
  > /dev/null

if [ "$?" -ne 0 ]
then
  exit 1
fi


# Install required software
if [ "$?" -eq 0 ]
then
  printf 'Installing required software\n'
  docker exec test_dummy "$TEST_DIR"/bootstrap.sh > /dev/null
fi
  
# Check syntax of role
if [ "$?" -eq 0 ]
then
  printf 'Checking syntax\n'
  docker exec test_dummy \
    ansible-playbook --syntax-check --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/test.yml
fi

# Run configuration test
if [ "$?" -eq 0 ]
then
  printf 'Running configuration playbook\n'
  docker exec test_dummy \
    ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/test.yml
fi

# Verify configuration
if [ "$?" -eq 0 ]
then
  printf 'Verifying configuration\n'
  docker exec test_dummy "$TEST_DIR"/verify.sh
fi

# Idempotentence test
if [ "$?" -eq 0 ]
then
  printf 'Checking idempotence of role\n'
  docker exec test_dummy \
        ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory \
                         "$TEST_DIR"/test.yml \
    | grep --quiet --regexp='changed=0.*failed=0' \
      && printf 'Idempotence test: pass\n' \
      || printf 'Idempotence test: fail\n'
fi

printf 'Cleaning up\n'
docker stop test_dummy > /dev/null
docker rm test_dummy > /dev/null
