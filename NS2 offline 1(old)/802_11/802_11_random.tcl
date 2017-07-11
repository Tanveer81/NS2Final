set num_nodes  [lindex $argv 0]; #20,40,60,80,100
set num_flows  [lindex $argv 1]; #10,20,30,40,50
set packets_per_second [lindex $argv 2]; #100,200,300,400,500
set coverage [lindex $argv 3]; #1x,2x,3x,4x,5x


set num_row 5 
set num_col [expr $num_nodes/$num_row];


set x_dim $coverage
set y_dim $coverage



set nm 802_11_random.nam
set tr 802_11_random.tr



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
Phy/WirelessPhy set CSThresh_ $dist(40m)
Phy/WirelessPhy set RXThresh_ $dist(40m)
Phy/WirelessPhy set TXThresh_ $dist(15m)

set topo       [new Topography]
$topo load_flatgrid $x_dim $y_dim



create-god $num_nodes




$ns_ node-config -adhocRouting	 DSDV\
				-llType 		 LL\
				-ifqType		 Queue/DropTail/PriQueue\
				-ifqLen 		 50\
				-macType 		 Mac/802_11\
				-phyType 		 Phy/WirelessPhy\
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

set x_start [expr $x_dim/($num_row*2)];
set y_start [expr $y_dim/($num_col*2)];

for {set i 0} {$i < $num_row} {incr i} {
	for {set j 0} {$j < $num_col} {incr j} {

		set x [expr $j+$i*$num_col]
		set node_($x) [$ns_ node]
		$node_($x) random-motion 0
		$node_($x) set X_ [expr $x_start+$j*($x_dim/$num_col*2)]
		$node_($x) set Y_ [expr $y_start+$i*($y_dim/$num_row*2)]
		$node_($x) set Z_ 0 

	}
}
puts "node creation complete"

########################################################

set x 0;
while {$x < $num_flows} {

    	set c [expr int(rand()*$num_nodes)]
    	set d [expr int(rand()*$num_nodes)]
		if {$c != $d} {

			set cbr($x) [new Application/Traffic/CBR]
			$cbr($x) set packetSize_ 500 ;#bytes
			$cbr($x) set interval_ [expr 1.0/$packets_per_second];#seconds
			$cbr($x) set rate_ 1.0Mb

			set udp($x) [new Agent/UDP]
			$ns_ attach-agent $node_($c) $udp($x)
			$cbr($x) attach-agent $udp($x)

			set null($x) [new Agent/Null]
			$ns_ attach-agent $node_($d) $null($x)
			$ns_ connect $udp($x) $null($x)

			incr x;

		}

}
puts "flow creation complete"

########################################################

proc finish {} {
	global ns_ tracefd namtrace nm
	$ns_ flush-trace
	close $tracefd
	close $namtrace
    #exec nam $nm &
    exit 0
}


set tt [expr rand()*$num_flows]

set i 0;
while {$i < $tt} {
#for {set i 0} {$i < $x} {incr i} {}
	set cv [expr rand()*$tt]
	set cv2 [expr rand()*($tt-$cv)]
	$ns_ at $cv "$cbr($i) start"
	$ns_ at [expr $cv+$cv2] "$cbr($i) stop"
	incr i;
};

$ns_ at [expr $tt+2] "finish"



for {set i 0} {$i < $num_nodes} {incr i} {
	$ns_ initial_node_pos $node_($i) 10
}



$ns_ run 
