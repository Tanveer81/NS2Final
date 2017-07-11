set num_nodes  [lindex $argv 0]; #20,40,60,80,100
set num_flows  [lindex $argv 1]; #10,20,30,40,50
set packets_per_second [lindex $argv 2]; #100,200,300,400,500
set coverage [lindex $argv 3]; #1x,2x,3x,4x,5x


set cbr_size 8 ; #[lindex $argv 2]; #4,8,16,32,64
set cbr_rate 1.0Mb
#set cbr_pckt_per_sec 500
set cbr_interval [expr 1.0/$packets_per_second] ;
set time_duration 5 ; #[lindex $argv 5] ;#50
set start_time 5 ;#100
set parallel_start_gap 0.0
set cross_start_gap 0.0

set sink_start_gap [expr 1.0/$num_flows]
set num_row 5 
set num_col [expr $num_nodes/$num_row];
set extra_time 10 ;

set x_dim [expr $coverage*15.0]
set y_dim [expr $coverage*15.0]



set nm 802_15_4_sink.nam
set tr 802_15_4_sink.tr



set ns_ [new Simulator]



set tracefd [open $tr w]
$ns_ trace-all $tracefd

set namtrace [open $nm w]
$ns_ namtrace-all-wireless $namtrace $x_dim $y_dim


set dist(5m)  7.69113e-06
set dist(9m)  2.37381e-06
set dist(10m) 1.92278e-06
set dist(11m) 1.58908e-06
set dist(12m) 1.33527e-06
set dist(13m) 1.13774e-06
set dist(14m) 9.81011e-07
set dist(15m) 8.54570e-07
set dist(16m) 7.51087e-07
set dist(20m) 4.80696e-07
set dist(25m) 3.07645e-07
set dist(30m) 2.13643e-07
set dist(35m) 1.56962e-07
set dist(40m) 1.20174e-07
Phy/WirelessPhy set CSThresh_ $dist(15m)
Phy/WirelessPhy set RXThresh_ $dist(15m)
Phy/WirelessPhy set TXThresh_ $dist(15m)


set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim



create-god $num_nodes




$ns_ node-config -adhocRouting	 AODV\
				-llType 		 LL\
				-ifqType		 Queue/DropTail/PriQueue\
				-ifqLen 		 50\
				-macType 		 Mac/802_15_4\
				-phyType 		 Phy/WirelessPhy/802_15_4\
				-antType 		 Antenna/OmniAntenna\
				-propType 		 Propagation/TwoRayGround\
				-channelType 	 Channel/WirelessChannel\
				-topoInstance 	 $topo\
				-energyModel 	 EnergyModel\
				-initialEnergy   1000\
				-rxPower  		 1560.6e-3\
				-txPower 		 1679.4e-3\
				-idlePower 		 869.4e-3\
				-sleepPower  	 37.8e-3\
				-transitionPower 176.695e-3\
				-transitionTime  2.36\
				-agentTrace		 ON\
				-routerTrace 	 OFF\
				-macTrace 		 ON\
				-movementTrace   OFF


#puts "start node creation"
for {set i 0} {$i < [expr $num_row*$num_col]} {incr i} {
	set node_($i) [$ns_ node]
#	$node_($i) random-motion 0
}

set x_start [expr $x_dim/($num_col*2)];
set y_start [expr $y_dim/($num_row*2)];
set i 0;
while {$i < $num_row } {
    for {set j 0} {$j < $num_col } {incr j} {
		set m [expr $i*$num_col+$j];
		set x_pos [expr $x_start+$j*($x_dim/$num_col*2)];
		set y_pos [expr $y_start+$i*($y_dim/$num_row*2)];
		$node_($m) set X_ $x_pos;
		$node_($m) set Y_ $y_pos;
		$node_($m) set Z_ 0.0
	}
    incr i;
}; 
#puts "node creation complete"


set sink_node [expr $num_nodes-1]

set rt 0
for {set i 1} {$i < [expr $num_flows+1]} {incr i} {

	set udp_([expr $i-1]) [new Agent/UDP]
	set null_([expr $i-1]) [new Agent/Null]
	
	set udp_node [expr ($i-1)%$sink_node] 
	set null_node $sink_node
	
	$ns_ attach-agent $node_($udp_node) $udp_($rt)
  	$ns_ attach-agent $node_($null_node) $null_($rt)
  	$ns_ connect $udp_($rt) $null_($rt)

  	set cbr_($rt) [new Application/Traffic/CBR]
	$cbr_($rt) set packetSize_ $cbr_size
	$cbr_($rt) set rate_ $cbr_rate
	$cbr_($rt) set interval_ $cbr_interval
	$cbr_($rt) attach-agent $udp_($rt)

	$ns_ at [expr $start_time+$i*$sink_start_gap+rand()] "$cbr_($rt) start"


	incr rt
} 

#puts "flow creation complete"



$ns_ at [expr $start_time+$time_duration +$extra_time] "finish"
$ns_ at [expr $start_time+$time_duration +$extra_time] "$ns_ nam-end-wireless [$ns_ now];  $ns_ halt"
#puts \"NS Exiting...\";

#$ns_ at [expr $start_time+$time_duration/2] "puts \"half of the simulation is finished\""
#$ns_ at [expr $start_time+$time_duration] "puts \"end of simulation duration\""
#$ns_ at [expr $start_time+$time_duration] "$node_([expr $i-2]) reset";


proc finish {} {
	global ns_ tracefd namtrace nm
	$ns_ flush-trace
	close $tracefd
	close $namtrace
    #exec nam $nm &
    exit 0
}


for {set i 0} {$i < $num_nodes} {incr i} {
	$ns_ initial_node_pos $node_($i) 10
}


#puts "Starting Simulation..."
$ns_ run 
