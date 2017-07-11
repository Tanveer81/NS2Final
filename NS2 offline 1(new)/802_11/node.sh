#!/bin/bash
i=20;

packetfinal="nodefinal.ps"

for (( j = 0; j < 5; j++ )); do
	 
	 graph[$j]="pdf/nodegraph$j.ps"

	 if [ "$j" == "0" ]; then
	 		xgr[$j]="pdf/node_throughput.xgr"
			printf "YUnitText: Throughput\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "1" ]; then
			xgr[$j]="pdf/node_delay.xgr"
			printf "YUnitText: Delay\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "2" ]; then
			xgr[$j]="pdf/node_delivery.xgr"
			printf "YUnitText: Delivery Ratio\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "3" ]; then
			xgr[$j]="pdf/node_dropratio.xgr"
			printf "YUnitText: Drop Ratio\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "4" ]; then
			xgr[$j]="pdf/node_energy.xgr"
			printf "YUnitText: Energy Consumption\nXUnitText: Num of Nodes\n\"\"\n0 0.0\n" > ${xgr[$j]}
		fi

done

while [ $i -le 100 ]

do
	ns 802_11_random.tcl $i 10 100 2
	awk -f rule_wireless_udp.awk 802_11_random.tr > 802_11.out
	echo "Node $i"
	l=0;
	while read line
	do
		printf "$i $line\n" >> ${xgr[$l]}
		l=$(($l+1))
	
	done < 802_11.out
	
	i=$(($i+20))
done	


for (( iii = 0; iii < 5; iii++ )); do
	xgraph -device ps -o ${graph[$iii]} ${xgr[$iii]}
done

gs -dBATCH -dNOPAUSE -q -sDEVICE=ps2write -sOutputFile=$packetfinal ${graph[0]} ${graph[1]} ${graph[2]} ${graph[3]} ${graph[4]}

#xdg-open $packetfinal 









 

