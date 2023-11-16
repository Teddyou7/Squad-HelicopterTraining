#!/bin/bash
#[2023.04.20-11.12.35:776][ 87]LogSquad: Player:=TSAR= Teddyou ActualDamage=62.000004 from Light莱特上校 caused by BP_M4A1_M68_Foregrip_Tracer_C_2147479517
#[2023.04.20-11.12.35:776][ 87]LogSquad: Player:=TSAR= Teddyou ActualDamage=62.000004 from Light莱特上校 caused by BP_M4A1_M68_Foregrip_Tracer_C_2147479517
#/home/steam/squad_server/SquadGame/Saved/Logs/SquadGame.log
while true
do
#删除旧的广播
find /home/steam/squad_server/shell/kill-kick.tmp -type f -mmin +1 -delete
#检查是否正常生成日志
LOGF=`find /home/steam/squad_server/SquadGame/Saved/Logs/SquadGame.log -type f -mmin -30|wc -l`
        if [ "$LOGF" -eq 0 ];then
                kill `ps -ef|grep server\/SquadGame |grep -v grep |awk '{print $2}'`
        fi
#检查击杀伤害
KILL=`cat /home/steam/squad_server/SquadGame/Saved/Logs/SquadGame.log |tail -100 |grep -v null |grep -vE UH60\|SA330\|MI8\|MI17\|CH146\|BP_MRH90_Mag58\|Z8G\|UH1Y\|Z8J | grep -E ActualDamage | tail -1`
#KILL=`cat /home/steam/squad_server/nohup.out |grep -v null |grep -E ActualDamage |tail -1`
R2=`echo ${KILL##*from }`
U2=`echo ${R2%%' caused'*}`
R1=`echo ${KILL##*Player:}`
U1=`echo ${R1%%' ActualDamage'*}`
        if [ "$U1" != "$U2" ];then
                /home/steam/squad_server/shell/rcon -p21114 -Pouyangwenguang AdminKick "${U2}" 训练场禁止对玩家造成伤害 
                #黄字广播
                ls /home/steam/squad_server/shell/kill-kick.tmp
                if [ $? -ne 0 ];then
                        /home/steam/squad_server/shell/rcon -Pouyangwenguang -p21114 AdminBroadcast 检查到“${U2}”对“${U1}”造成伤害，已被踢出警告。
                fi
                touch /home/steam/squad_server/shell/kill-kick.tmp
        fi
sleep 3
done
