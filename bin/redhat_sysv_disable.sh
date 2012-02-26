#!/bin/sh

# Disables specified services on Redhat based systems that use SysV startup
# scripts. This will not work with Systemd based startup scripts. This must
# be run as root in order to work.
#
# Simply get a list of all SysV based services by running the following
# command:
# chkconfig --list | grep ":on" | awk '{print $1}' > /tmp/services.txt
#
# Go through this list and remove any services which you wish to leave enabled
# in their default run levels. Then run this script as root in order to
# disable all remaining services in all runlevels.

if [ $(id -u) -ne 0 ]; then
  echo "Re-run as root to disable services"
  exit 1
fi

for service in $(cat /tmp/services.txt); do
  chkconfig --levels 0123456 $service off
done

# Clean up services file which should no longer be needed.
rm /tmp/services.txt
