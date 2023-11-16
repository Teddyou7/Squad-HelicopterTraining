#!/bin/bash
source ./config.ini
while true
do
#删除旧的广播
find ./turret-kick.tmp -type f -mmin +1 -delete
#检查是否正常生成日志
#LOGF=`find $GAMELOG -type f -mmin -30|wc -l`
#        if [ "$LOGF" -eq 0 ];then
#                kill `ps -ef|grep server\/SquadGame |grep -v grep |awk '{print $2}'`
#        fi

TUR=`cat $GAMELOG |tail -150 |grep -vE Doorgun\|health\|TakeDamage | grep -iE Turret\|CROWS\|Baseplate\|Tripod\|23Vehicle | tail -1 | awk -F '=' '{print $2}'|sed  's/ Pawn$//g'`

if [ "${TUR}" != '' ];then 
        ./rcon -p$PORT -P$PASSWD AdminKick "${TUR}" 训练场禁止使用炮手位置或固定武器
        #黄字广播
        ls ./turret-kick.tmp
                if [ $? -ne 0 ];then
                        ./rcon -p$PORT -P$PASSWD AdminBroadcast 检查到“${TUR}”使用固定武器或载具炮手位置，已被踢出警告。
                fi
        touch ./turret-kick.tmp
fi
sleep 3
done
