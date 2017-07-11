#!/bin/bash
i=1;

packetfinal="coveragefinal.ps"

for (( j = 0; j < 5; j++ )); do
	 
	 graph[$j]="pdf/coveragegraph$j.ps"

	 if [ "$j" == "0" ]; then
	 		xgr[$j]="pdf/coverage_throughput.xgr"
			printf "YUnitText: Throughput\nXUnitText: Num of Coverage\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "1" ]; then
			xgr[$j]="pdf/coverage_delay.xgr"
			printf "YUnitText: Delay\nXUnitText: Num of Coverage\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "2" ]; then
			xgr[$j]="pdf/coverage_delivery.xgr"
			printf "YUnitText: Delivery Ratio\nXUnitText: Num of Coverage\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "3" ]; then
			xgr[$j]="pdf/coverage_dropratio.xgr"
			printf "YUnitText: Drop Ratio\nXUnitText: Num of Coverage\n\"\"\n0 0.0\n" > ${xgr[$j]}
		elif [ "$j" == "4" ]; then
			xgr[$j]="pdf/coverage_energy.xgr"
			printf "YUnitText: Energy Consumption\nXUnitText: Num of Coverage\n\"\"\n0 0.0\n" > ${xgr[$j]}
		fi

done

while [ $i -le 5 ]

do
	#ns 802_15_4_sink.tcl $node_cur $flow_start $pack_start $coverage_start
	ns 802_15_4_sink.tcl 40 10 100 $i 
	awk -f rule_wireless_udp.awk 802_15_4_sink.tr > 802_11.out
	echo "Coverage $i"
	l=0;
	while read line
	do
		printf "$i $line\n" >> ${xgr[$l]}
		l=$(($l+1))
	
	done < 802_11.out
	
	i=$(($i+1))
done	

#for (( j = 0; j < 5; j++ )); do
#	xgraph ${xgr[$j]}
#done
#xgraph node_vs_throughput.xgr

for (( iii = 0; iii < 5; iii++ )); do
	xgraph -device ps -o ${graph[$iii]} ${xgr[$iii]}
done

gs -dBATCH -dNOPAUSE -q -sDEVICE=ps2write -sOutputFile=$packetfinal ${graph[0]} ${graph[1]} ${graph[2]} ${graph[3]} ${graph[4]}

#xdg-open $packetfinal 









 

