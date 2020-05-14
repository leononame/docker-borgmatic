# Borgmatic Container

<img src="https://github.com/witten/borgmatic/raw/master/docs/static/borgmatic.png" />

## Description

A [borgmatic](https://github.com/witten/borgmatic) container that manages multiple configuration files based on [docker-borgmatic](https://github.com/b3vis/docker-borgmatic).

It uses cron to run the backups at a time you can configure in `data/borgmatic.d/crontab.txt`.

### Usage

To set your backup timing and configuration, you will need to create [crontab.txt](data/borgmatic.d/crontab.txt) and your borgmatic [config.yaml](data/borgmatic.d/config.yaml) and mount these files into the `/etc/borgmatic.d/` directory. When the container starts it creates the crontab from `crontab.txt` and starts crond. By cloning this repo in `/opt/docker/`, you will have a working setup to get started.

### Example run command

To init the repo with encryption, run:

```
docker exec borgmatic \
sh -c "borgmatic --init --encryption repokey-blake2"
```

### Layout

#### /mnt/source

Your data you wish to backup. For _some_ safety you may want to mount read-only. Borgmatic is running as root so all files can be backed up.

#### /etc/borgmatic.d

Where you need to create crontab.txt and your borgmatic config.yml

- To generate an example borgmatic configuration, run:

```
docker exec borgmatic \
sh -c "cd && generate-borgmatic-config -d /etc/borgmatic.d/config.yaml"
```

- crontab.txt example: In this file set the time you wish for your backups to take place default is 1am every day. In here you can add any other tasks you want ran

```
0 1 * * * PATH=$PATH:/usr/bin /usr/bin/borgmatic --stats -v 0 2>&1
```

#### /root/.config/borg

Here the borg config and keys for keyfile encryption modes are stored. Make sure to backup your keyfiles! Also needed when encryption is set to none.

#### /root/.ssh

Mount either your own .ssh here or create a new one with ssh keys in for your remote repo locations.

#### /root/.cache/borg

A non-volatile place to store the borg chunk cache.

### Environment

- Time zone, e.g. `TZ="Europe/Berlin"'`.
- SSH parameters, e.g. `BORG_RSH="ssh -i /root/.ssh/id_ed25519 -p 50221"`
- BORG_RSH="ssh -i /root/.ssh/id_ed25519 -p 50221"
- Repository passphrase, e.g. `BORG_PASSPHRASE="DonNotMissToChangeYourPassphrase"`

### Docker Compose

- Prepare your configuration
  1. `cp .env.template .env`
  2. Set your environment and adapt volumes as needed
- To start the container for backup: `docker-compose up -d`
- For backup restore:
  1. Stop the backup container: `docker-compose down`
  2. Run an interactive shell: `docker-compose -f docker-compose.yml -f docker-compose.restore.yml run borgmatic`
  3. Fuse-mount the backup: `borg mount /mnt/borg-repository <mount_point>`
  4. Restore your files
  5. Finally unmount and exit: `borg umount <mount_point> && exit`.
- In case Borg fails to create/acquire a lock: `borg break-lock /mnt/repository`
