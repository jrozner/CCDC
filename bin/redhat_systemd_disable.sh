#!/bin/sh

# Disables specified services on Redhat based systems that use Systemd startup
# scripts. This must be run as root in order to work.
#
# Simply get a list of all Systemd based services by running the following
# command:
# systemctl --full --no-page -t service | awk '{print $1}' > /tmp/services.txt
#
# Go through this list and remove any services which you wish to leave enabled
# in their default run levels. Then run this script as root in order to
# disable all remaining services in all runlevels.

if [ $(id -u) -ne 0 ]; then
  echo "Re-run as root to disable services"
  exit 1
fi

for service in $(cat /tmp/services.txt); do
  systemctl disable $service
  systemctl stop $service
done

# Clean up services file which should no longer be needed.
rm /tmp/services.txt
