#!/bin/bash
#玩家加入房间自动化天气播报脚本

ss -nutlp |grep Squad |grep -v tcp|grep -v 26301|awk '{print $5}' > /home/steam/squad_server/shell/tmp/port_tmp
rm -rf /home/steam/squad_server/shell/tmp/new_steamid_tmp

while true
do

sleep 3

USER_TMP1=`cat /home/steam/squad_server/SquadGame/Saved/Logs/SquadGame.log |grep "Login request"| tail -1`
USER_TMP1_A=`echo ${USER_TMP1##*?UNKNOWN \[}`
USER_TMP1_B=`echo ${USER_TMP1_A%%'] platform'*}`
USER_NAME_TMP_A=`echo ${USER_TMP1##*?Name=}`
USER_NAME_TMP_B=`echo ${USER_NAME_TMP_A%%' userId:'*}`
USER_NAME=$USER_NAME_TMP_B
USER_P2PID=$USER_TMP1_B
USER_TMP2=`cat /home/steam/squad_server/SquadGame/Saved/Logs/SquadGame.log |grep $USER_P2PID |grep "LogOnline: STEAM: Adding P2P connection information with user"| tail -1`
USER_TMP2_A=`echo ${USER_TMP2##*?with user }`
USER_TMP2_B=`echo ${USER_TMP2_A%%' (Name: UNKNOWN'*}`
NEW_USER_STEAMID=$USER_TMP2_B

NEW_USER_C=`cat /home/steam/squad_server/shell/tmp/new_steamid_tmp |grep $NEW_USER_STEAMID| wc -l`

find /home/steam/squad_server/shell/tmp/steamid/ -type f -mmin +1 -delete

ls /home/steam/squad_server/shell/tmp/steamid/$NEW_USER_STEAMID
if [ $? -eq 0 ];then
        continue
fi


NEW_PORT_TMP=(`ss -nutlp |grep Squad |grep -v tcp|grep -v 26301|awk '{print $5}'`)

for I in ${!NEW_PORT_TMP[@]}
do
        NEW_PORT_TMP_C=`cat /home/steam/squad_server/shell/tmp/port_tmp |grep ${NEW_PORT_TMP[${I}]}|wc -l`
                if [ $NEW_PORT_TMP_C -eq 0 ];then
                        NEW_PORT_TMP_IP=${NEW_PORT_TMP[${I}]}
                        echo "$NEW_PORT_TMP_IP" >> /home/steam/squad_server/shell/tmp/port_tmp
                        break
                else
                        continue
                fi
done

NEW_PORT=`echo ${NEW_PORT_TMP_IP##*'10.0.0.3:'}`

sudo timeout 3 tcpdump -i eth0 -n udp port $NEW_PORT -c 10  > /home/steam/squad_server/shell/tmp/pac/NEW_USER

IPS=(`cat /home/steam/squad_server/shell/tmp/pac/NEW_USER | awk '{print $5}' | awk -F: '{print $1}'`)
COUNTER=0
IPSUM=${#IPS[@]}
while true
do
        if [ $IPSUM -eq 0 ];then
                USER_IP_PORT=null
                break
        fi
        if [ ${IPS[$COUNTER]} != "10.0.0.3.${NEW_PORT}" ];then
                USER_IP_PORT=${IPS[$COUNTER]}
                break
        fi
        COUNTER=$((COUNTER+1))
        if [ $COUNTER -eq 100 ];then
                USER_IP_PORT=null
                break
        fi 
done
if [ $USER_IP_PORT == "null" ];then
        echo "Err! USER_IP_PORT 获取失败，可能是在启动之前就加入了服务器。"
        continue
fi
USER_IP=`echo $USER_IP_PORT | sed -r 's/\.[a-z0-9]{2,5}$//g'`

echo "$NEW_USER_STEAMID:$USER_IP" >> /home/steam/squad_server/shell/tmp/userinfo

curl "http://restapi.amap.com/v3/ip?key=[GaoDeAPIKey--https://console.amap.com/dev/index]&ip=$USER_IP" > /home/steam/squad_server/shell/tmp/ip_info_tmp
IP_INFO="/home/steam/squad_server/shell/tmp/ip_info_tmp"
CITY=`cat $IP_INFO |/usr/bin/jq '.city'|sed -r 's/\"//g'`
PROVINCE=`cat $IP_INFO |/usr/bin/jq '.province'|sed -r 's/\"//g'`
CITY_CODE=`cat $IP_INFO |/usr/bin/jq '.adcode'|sed -r 's/\"//g'`

curl "http://restapi.amap.com/v3/weather/weatherInfo?key=[GaoDeAPIKey--https://console.amap.com/dev/index]&city=$CITY_CODE" > /home/steam/squad_server/shell/tmp/weatherInfo_info_tmp
WEARHER_INFO="/home/steam/squad_server/shell/tmp/weatherInfo_info_tmp"
WEARHER=`cat weatherInfo_info_tmp |jq ".lives"|sed 's/null//g' |sed 's/\[//g'|sed 's/\]//g'|jq .weather |sed 's/"//g'`
TEMPERATURE=`cat weatherInfo_info_tmp |jq ".lives"|sed 's/null//g' |sed 's/\[//g'|sed 's/\]//g'|jq .temperature |sed 's/"//g'`

if [ $CITY == '[]' ];then
        echo "Err! CITY is null"
        continue
fi

if [ $NEW_USER_C -eq 0 ];then
        echo "$NEW_USER_STEAMID" >> /home/steam/squad_server/shell/tmp/new_steamid_tmp
else
        continue
fi

#/usr/local/bin/mcrcon  -P 111 -p XXX "AdminBroadcast 欢迎加入服务器，您所在的${PROVINCE}${CITY}天气${WEARHER}，实时温度为${TEMPERATURE}摄氏度。" ok 
/home/steam/squad_server/shell/tmp/AdminBroadcast.sh "欢迎${USER_NAME}加入服务器，您所在的${CITY}天气${WEARHER}，实时温度为${TEMPERATURE}摄氏度。" &
#echo 欢迎加入服务器，您所在的${PROVINCE}${CITY}天气${WEARHER}，实时温度为${TEMPERATURE}摄氏度。

touch /home/steam/squad_server/shell/tmp/steamid/$NEW_USER_STEAMID


done
