#!bin/bash
source ./config.ini
DIR=$(echo $(cd `dirname $0`; pwd))
cd $DIR

ls ./rcon
if [ $? -ne 0 ];then
  gcc -o ./rcon ./rcon.c
  chmod +x ./rcon
fi

ls $GAMELOG
if [ $? -ne 0 ];then
  echo "GAMELOG Error!"
  exit
fi

nohup $DIR/SkipTime.sh > /dev/null &
nohup $DIR/kick-kill.sh > /dev/null &
nohup $DIR/kick-turret.sh > /dev/null &

echo "Start complete!"
