#!/bin/bash
#自动打乱脚本；注意！本脚本通过Apache的HTTPD-CGI调用，但也是可以通过在后台运行，不需要传入参数。

RCON_IP=127.0.0.1
RCON_PASSWD=XXXXXX
RCON_PORT=21114
#设置临时文件路径
FILE_TMP=/FILE

echo "Content-type:text/html;charset=UTF8"
echo ""
echo "正在操作，等待回显。<br>"

/usr/local/bin/mcrcon -H $RCON_IP -P $RCON_PORT -p "$RCON_PASSWD" "AdminBroadcast 服务器随机打乱脚本已启动，即将进行打乱操作" ok
sleep 1
/home/steam/restart/rcon-tsc-shuf -a$RCON_IP -P"$RCON_PASSWD" -p$RCON_PORT  ListPlayers |grep -Ev "Active Players"\|Disconnect > $FILE_TMP
SHUFW=`cat $FILE_TMP|wc -l`
if [ $SHUFW -lt 2 ];then
        echo "<br>获取玩家数过低，可能存在异常，请重新尝试。"
        exit
fi 

sleep 1

WC=`cat $FILE_TMP|wc -l`
PT=`expr $WC / 2`
PL=(`cat $FILE_TMP|awk '{print $2}'|shuf -n $PT`)
COUNTER=0
PLSUM=${#PL[@]}
echo "<br>打乱人数为${PT}人。<br><br>"

while true
do
  if [ $PT -eq 0 ];then
   break
  fi
  if [ $COUNTER -eq $PLSUM ];then
   break
  fi 
/usr/local/bin/mcrcon -H $RCON_IP -P $RCON_PORT -p "$RCON_PASSWD" "AdminWarnById ${PL[$COUNTER]} 您已被打乱程序选中。" ok
echo "<br>"
/usr/local/bin/mcrcon -H $RCON_IP -P $RCON_PORT -p "$RCON_PASSWD" "AdminForceTeamChangeById ${PL[$COUNTER]} " ok
echo "<br>"
 COUNTER=$((COUNTER+1))
done
