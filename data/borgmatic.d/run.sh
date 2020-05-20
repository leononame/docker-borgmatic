#!/bin/bash

name=$(printf '%s\n' "$1" | awk '{ print toupper($0) }')
varname=BORG_PASSPHRASE_$name


PATH=$PATH:/usr/bin BORG_PASSPHRASE=${!varname} /usr/bin/borgmatic -c "$1".yaml