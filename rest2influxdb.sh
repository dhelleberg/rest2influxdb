#!/bin/bash
# This script reads the values of an item from openhab via REST and imports the data to influxdb
# useage: get_item_states.sh <itemname>


itemname="$1"

if [ -z $itemname ]
then
  echo "Please define Item!"
  exit 0
fi

source ./config.cfg

# convert historical times to unix timestamps,
tenyearsago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="10 years ago"`
oneyearago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="-12 months 28 days ago"`
onemonthago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="29 days ago"`
oneweekago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="-6 days -23 hours 59 minutes ago"`
onedayago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="-23 hours 59 minutes ago"`
eighthoursago=`date +"%Y-%m-%dT%H:%M:%S%:z" --date="-7 hours 59 minutes ago"`


# print timestamps
echo ""
echo "### timestamps"
echo "item: $itemname"
echo "10y:  $tenyearsago"
echo "1y:   $oneyearago"
echo "1m:   $onemonthago"
echo "1w:   $oneweekago"
echo "1d:   $onedayago"
echo "8h:   $eighthoursago"

resturl="http://$openhabserver:$openhabport/rest/persistence/items/$itemname?serviceId=$serviceid"

# get values and write to different files
curl -G -X GET --header "Accept: application/json" --data-urlencode "starttime=${tenyearsago}" "$resturl"  > ${itemname}_10y.json


echo "converting"

node convertJson2influx.js $itemname

  # print import command
#  echo "curl -i -XPOST -u $influxuser:$influxpw 'http://$influxserver:$influxport/write?db=$influxdatbase' --data-binary @${itemname}_${linestart}.txt"
  # execute import command
  echo "curl -i -XPOST -u $influxuser:$influxpw "http://$influxserver:$influxport/write?db=$influxdatbase" --data-binary @${itemname}.json "

done

echo ""
echo "### delete temporary files"
#irm ${itemname}*

exit 0