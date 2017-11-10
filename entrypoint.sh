#!/bin/sh

echo "Starting knxd service."

ARGS=$@
echo "ARGS: $ARGS"

CONFIG_PATH=/etc/knxd

if [ ! -e "$CONFIG_PATH/knxd.ini.input" ]; then
    echo "No config file found, using example file"
    cp /root/knxd.ini.input $CONFIG_PATH/knxd.ini.input;
fi

# Get ownership
[ -e $CONFIG_PATH/knxd.ini.input ] && chown knxd:knxd $CONFIG_PATH/knxd.ini.input

# Purge old config, which may have wrong USB interface
rm -f $CONFIG_PATH/knxd.ini
cp $CONFIG_PATH/knxd.ini.input $CONFIG_PATH/knxd.ini

# Add code to find correct USB interface,
# and patch up the config file.
tail -n 1 $CONFIG_PATH/knxd.ini | grep -q "\[usb\]"
if [ $? -eq 0 ]; then
  BUS=`findknxusb  | cut -s -f 2 -d : | sed 's/ //g' | sed '/^\s*$/d'`
  DEV=`findknxusb  | cut -s -f 3 -d : | sed 's/ //g' | sed '/^\s*$/d'`
  echo "bus = $BUS" >> $CONFIG_PATH/knxd.ini
  echo "device = $DEV" >> $CONFIG_PATH/knxd.ini;
  # Make sure the device is accessible to the knxd user
  chown knxd:knxd /dev/bus/usb/00$BUS/00$DEV
fi

echo "Press <ctrl>-c to abort"
su -s /bin/sh -c "knxd $ARGS" knxd

# Workaround because knxd always forks to background
while [ true ] ; do
    sleep 5
done
