#!/bin/bash

name=$1
uppername=$(printf '%s\n' "$name" | awk '{ print toupper($0) }')
varname=BORG_PASSPHRASE_$uppername

shift

PATH=$PATH:/usr/bin BORG_PASSPHRASE=${!varname} /usr/bin/borgmatic -c /etc/borgmatic.d/"$name".yaml "$@"
