#!/usr/bin/env bash

RHOST=azureuser@xxx.xxx.xx.xxx

scp ../infra/id_vm.pub $RHOST:~/.ssh/id_rsa.pub
scp ../infra/id_vm $RHOST:~/.ssh/id_rsa
ssh $RHOST "chmod 400 ~/.ssh/id_rsa*"
