#!/bin/bash
if [ $# -ne 2 ];
then
  echo "Syntax: $(basename $0) <ftp_username> <ftp_password>"
  exit 1
fi

ftp_username="$1"
ftp_password="$2"
sync_snapshots_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cmd_sync_snapshots="$sync_snapshots_dir/sync_snapshots.sh"
cron_sync_snapshots="/etc/cron.hourly/xeno_sync_snapshots"

# Create cron job.
sudo echo -e "#!/bin/bash\n/bin/bash $cmd_sync_snapshots $ftp_username $ftp_password" > $cron_sync_snapshots
chmod u+x $cron_sync_snapshots

# Reset configuration file.
sudo cp /boot/config.txt /boot/config.txt.bckp
sudo cp $sync_snapshots_dir/config.xeno_pi.txt /boot/config.txt
