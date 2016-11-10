#! /bin/bash

readonly distribution=centos
readonly version=6
readonly ROLE_DIR=/etc/ansible/roles/CyVerse-Ansible.rabbitmq-vhost
readonly TEST_DIR="$ROLE_DIR"/tests


# Start the container
printf '\n--> Starting docker container\n'
docker run --detach --interactive --tty --name=test_dummy --volume="$PWD"/..:"$ROLE_DIR":rw \
           cyverse/ansible-test:latest-"$distribution"-"$version" bash \
  > /dev/null
err="$?"

# Install required software
if [ "$err" -eq 0 ]
then
  printf '\n--> Installing required software\n'
  docker exec test_dummy "$TEST_DIR"/bootstrap.sh > /dev/null
  err="$?"
fi

# Check syntax of role
if [ "$err" -eq 0 ]
then
  printf '\n--> Checking syntax\n'
  docker exec test_dummy \
    ansible-playbook --syntax-check --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/main.yml
  err="$?"
fi

# Run configuration test
if [ "$err" -eq 0 ]
then
  printf '\n--> Running configuration playbook\n'
  docker exec test_dummy \
    ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory "$TEST_DIR"/main.yml
  err="$?"
fi

# Idempotentence test
if [ "$err" -eq 0 ]
then
  printf '\n--> Checking idempotence of role\n'
  docker exec test_dummy \
      ansible-playbook --connection=local --inventory-file="$TEST_DIR"/inventory --skip-tags=test \
                       "$TEST_DIR"/main.yml \
    | grep --quiet --regexp='changed=0.*failed=0' \
      && printf 'Idempotence test: pass\n' \
      || printf 'Idempotence test: fail\n'
fi

printf '\n--> Cleaning up\n'
docker stop test_dummy > /dev/null
e2="$?"
if [ "$e2" -ne 0 ]
then
  err="$e2"
fi

docker rm test_dummy > /dev/null
e2="$?"
if [ "$e2" -ne 0 ]
then
  err="$e2"
fi

exit "$err"
