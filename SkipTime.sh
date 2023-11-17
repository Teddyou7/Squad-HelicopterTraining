#!/bin/bash
#开局自动加速，刷入解除限制指令 20230605 Teddyou

while true
do
STT=`cat $GAMELOG |grep StartLoadingDestination | sed 's/[^0-9]//g' | grep -oP '[0-9]{14}'|tail -1`
STTD=`echo "${STT:0:4}-${STT:4:2}-${STT:6:2} ${STT:8:2}:${STT:10:2}:${STT:12:2}"`
STTC=`date -d "$STTD" +%s`
TM=`expr $STTC + 28800`
TO=`date +%s`
TC=`expr $TO - $TM`

  if [ "$TC" -lt 15 ];then
        ./rcon -p$PORT -P$PASSWD AdminSlomo 20
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminForceAllVehicleAvailability 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminForceAllRoleAvailability 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminForceAllDeployableAvailability 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminDisableVehicleTeamRequirement 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminForceAllRoleAvailability 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminDisableVehicleKitRequirement 1
        sleep 2
        ./rcon -p$PORT -P$PASSWD AdminNoRespawnTimer 1
        sleep 7
        ./rcon -p$PORT -P$PASSWD AdminSlomo 1
  fi
sleep 3
done 
