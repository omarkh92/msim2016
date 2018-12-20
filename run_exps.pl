#!/usr/bin/perl -W

use strict;
use threads;
use Thread::Queue;

my $inst_cnt = 15000000; 

my %expts = (
	'baseline' => "-alg1::enable 0 -alg1::brupdate 0 -alg1::brupdate_cond 0 -max:inst ${inst_cnt} ",
	'bu0c0' =>      "-alg1::enable 1 -alg1::brupdate 0 -alg1::brupdate_cond 0 -max:inst ${inst_cnt} ",
	'bu0c1' =>      "-alg1::enable 1 -alg1::brupdate 0 -alg1::brupdate_cond 1 -max:inst ${inst_cnt} ",
	'bu1c0' =>      "-alg1::enable 1 -alg1::brupdate 1 -alg1::brupdate_cond 0 -max:inst ${inst_cnt} ",
	'bu1c1' =>      "-alg1::enable 1 -alg1::brupdate 1 -alg1::brupdate_cond 1 -max:inst ${inst_cnt} ",
			
);


my %bench= (
	'gobmk'=>"spec2K6/gobmk.arg",
	'leslie3d'=>"spec2K6/leslie3d.arg" ,
	'crafty'=>"spec2K/crafty.arg",
	'galgel'=>"spec2K/galgel.arg",
	'gromacs'=>"spec2K6/gromacs.arg",
	'libquantum'=>"spec2K6/libquantum.arg",
	'vpr'=>"spec2K/vpr.arg",
	'mcf'=>"spec2K6/mcf.arg"
	
);

my @array;
foreach my $keyb(keys %bench){
	my $valueb=$bench{$keyb};
	foreach my $key(keys %expts){
		my $value=$expts{$key};
		my $cmd = "./sim-outorder ".$value." ".$valueb.">& $keyb.$key.log";
		print "Adding run cmd for $cmd\n";
		push(@array,$cmd);
	}
	#./sim-outorder -
}


sub getWorkItems {
    my $cmd = shift @array;
    return $cmd;
}

sub worker {
    my $tid = threads->tid;
    my( $Qwork, $Qresults ) = @_;
    while( my $work = $Qwork->dequeue ) {
        my $result;

        ## Process $work to produce $result ##
	print "Thread $tid Running $work\n";
	system ($work);
        $result = "$tid : result for workitem $work\n";
        $Qresults->enqueue( $result );
    }
    $Qresults->enqueue( undef ); ## Signal this thread is finished
}

our $THREADS = 4;
my $Qwork = new Thread::Queue;
my $Qresults = new Thread::Queue;

## Create the pool of workers
my @pool = map{
    threads->create( \&worker, $Qwork, $Qresults )
} 1 .. $THREADS;

## Get the work items (from somewhere)
## and queue them up for the workers
while( my $workItem = getWorkItems() ) {
    $Qwork->enqueue( $workItem );
}

## Tell the workers there are no more work items
$Qwork->enqueue( (undef) x $THREADS );

## Process the results as they become available
## until all the workers say they are finished.
for ( 1 .. $THREADS ) {
    while( my $result = $Qresults->dequeue ) {
        ## Do something with the result ##
        #print $result;
    }
}

## Clean up the threads
$_->join for @pool;
