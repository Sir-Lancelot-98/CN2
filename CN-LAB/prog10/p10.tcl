set val(chan)   Channel/WirelessChannel
set val(prop)   Propagation/TwoRayGround
set val(netif)  Phy/WirelessPhy
set val(mac)    Mac/802_11
#set val(ifq)    CMUPriQueue
set val(ifq)    Queue/DropTail/PriQueue
set val(ll)     LL
set val(ant)    Antenna/OmniAntenna
set val(x)      500
set val(y)      400  
set val(ifqlen) 20
set val(nn)     5
set val(stop)   60.0
set val(rp)  	AODV

set ns_ [new Simulator]
set tracefd [open out10.tr w]
$ns_ trace-all $tracefd

set namtrace [open out10.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop [new $val(prop)]

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)


create-god $val(nn)

$ns_ node-config -adhocRouting $val(rp) \
           -llType $val(ll) \
           -macType $val(mac) \
           -ifqType $val(ifq) \
           -ifqLen $val(ifqlen) \
           -antType  $val(ant) \
           -propType $val(prop) \
           -phyType $val(netif) \
           -channelType $val(chan) \
           -topoInstance $topo \
           -agentTrace ON \
           -routerTrace ON \
           -IncomingErrProc "uniformErr"\
           -OutgoimgErrProc "uniformErr"\
           -macTrace ON
           
proc uniformErr {} {
set err [new ErrorModel]
$err unit pkt
$err set rate_ 0.10
return $err
}     
for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
    }
$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

$node_(3) set X_ 180.0
$node_(3) set Y_ 300.0
$node_(3) set Z_ 0.0

$node_(4) set X_ 300.0
$node_(4) set Y_ 300.0
$node_(4) set Z_ 0.0
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ initial_node_pos $node_($i) 40
    }

$ns_ at 1.0 "$node_(0) setdest 10.0 10.0 50.0"
$ns_ at 1.0 "$node_(1) setdest 10.0 100.0 50.0"
$ns_ at 1.0 "$node_(2) setdest 50.0 50.0 50.0"
$ns_ at 1.0 "$node_(3) setdest 100.0 100.0 50.0"
$ns_ at 1.0 "$node_(4) setdest 100.0 10.0 50.0"
 
set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp0
$ns_ attach-agent $node_(2) $sink0
$ns_ connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp1
$ns_ attach-agent $node_(2) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns_ at 1.0 "$ftp0 start"
$ns_ at 50.0 "$ftp0 stop"

$ns_ at 2.0 "$ftp1 start"
$ns_ at 40.0 "$ftp1 stop"

exec nam out10.nam &

for {set i 0} {$i < $val(nn) } {incr i} {
   $ns_ at $val(stop) "$node_($i) reset";
   }
   
   $ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"
   puts "Starting Simualtion..."
  
$ns_ run   

