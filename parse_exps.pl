#!/usr/bin/perl -W

use strict;

my %STATS;

my %STH =
(

#note to self: spec br and depth dont have whitespace after[d]:
	'IPC' => '^\s*sim_IPC\s+(\S+)\s+'
	#,'SMTQ_Enable' => '^SMTQ\s+Enable\:\s+(\d)'
	#SMTQ Enable: 0, IQ 1. RF 1. SPEC 1
	#,'IQ_Enable'=> '\,\s+IQ\s+(\d)'	
	#,'RF_Enable'=> '\.\s+RF\s+(\d)'
	#,'SPEC_Enable'=> '\.\s+SPEC\s+(\d)'
	#TH_CYCLES[0]: 2 out of  684557, pct 0.00029216
	#,'TH_Cycles_'=>'^TH\_CYCLES\[(\d)\]\:\s+(\d+) out'
	#,'TH_Cycles_pct_'=> '^TH\_CYCLES\[(\d)\].*\, pct (\S+)\s*$'
	#BP_MISS[0]: 20 out of  53695, pct 0.0372474
	#,'BP_MISS_'=>'^BP\_MISS\[(\d)\]\:\s+(\d+) out'
	,'BP_MISS_pct_'=> '^BP\_MISS\[(\d)\].*\, pct (\S+)\s*$'
	#IQ_THs[0]: 0
	#,'IQ_THs_'=>'^IQ\_THs\[(\d)\]\:\s+(\d+)'
	#RF_THs[0]: 0
	#,'RF_THs_'=>'^RF\_THs\[(\d)\]\:\s+(\d+)'
	#SPEC_BR[0]:1
	#,'SPEC_BR_'=>'^SPEC\_BR\[(\d)\]\:\s*(\d+)'
	#SPEC_DEPTH[0]:17
	#,'SPEC_DEPTH_'=>'^SPEC\_DEPTH\[(\d)\]\:\s*(\d+)'
	#MAX_SPEC_DEPTH[0]: 96
	#,'MAX_SPEC_DEPTH_'=>'^MAX\_SPEC\_DEPTH\[(\d)\]\:\s*(\d+)'
	#AVG_SPEC_DEPTH[0]: 23.7581
	,'AVG_SPEC_DEPTH_'=>'^AVG\_SPEC\_DEPTH\[(\d)\]\:\s*(\S+)'
	#AVG_IQ_SIZE[0]: 103.044
	,'AVG_IQ_SIZE_'=>'^AVG\_IQ\_SIZE\[(\d)\]\:\s*(\S+)'
	#AVG_RF_INT_SIZE[0]: 0
	,'AVG_RF_INT_SIZE_'=>'^AVG\_RF\_INT\_SIZE\[(\d)\]\:\s*(\S+)'
	#AVG_RF_FLT_SIZE[0]: 0
	,'AVG_RF_FLT_SIZE_'=>'^AVG\_RF\_FLT\_SIZE\[(\d)\]\:\s*(\S+)'
	#TH_SPEC_CYCLES[0]: 2
	#,'TH_SPEC_CYCLES_'=>'^TH\_SPEC\_CYCLES\[(\d)\]\:\s*(\d+)'
	#IPC for thread 0 = 2.1912
	#,'IPC_FOR_THREAD_'=>'^IPC for thread (\d) \= (\S+)$'
	#TH_SPEC_CYCLES_PCT[2]: 838021.77332
	#,'TH_SPEC_CYCLES_PCT_'=>'^TH\_SPEC\_CYCLES\_PCT\[(\d)\]\:\s*(\S+)\s*'
	
	
);

my @files = glob("*.log");

foreach my $element(@files){	
	unless ($element=~ m/(\w*)\.(\w*)\.log/) {
		print "===== WARNING ===== Unsupported log name '" . $element . "'\n";
		next;
	}
	my $bench = $1;
	my $exp = $2;
	open (my $FILE, "<", $element);
	
	while (my $LN = <$FILE>) {
		chomp $LN;
		while ((my $key, my $val) = each (%STH)) {
			if ($LN =~ /$val/) {
				if (defined $2) {
						$STATS{$bench}{$exp}{$key . $1} = $2;						
				} else {
					$STATS{$bench}{$exp}{$key} = $1;
				}			
			}
		}		
	}
}


print "bench,exp,";
my $k1 = (sort keys %STATS)[0];
my $v1 = $STATS{$k1};
my $k2 = (sort keys %$v1)[0];
my $v2 = $STATS{$k1}{$k2};	
print join (',' , sort keys %$v2);
print "\n";

foreach my $k1 (sort keys %STATS) {
	my $v1 = $STATS{$k1};	
	foreach my $k2 (sort keys %$v1) {
		my $v2 = $STATS{$k1}{$k2};
		print "$k1,$k2";		
		foreach my $k3 (sort keys %$v2) {
			my $v3 = $STATS{$k1}{$k2}{$k3};
			print ",$v3";
		}
		print "\n";	
	}	
}



#THROUGHPUT IPC: 2.1913

#IPC for thread 0 = 2.1912
 #----- SMTQ STATS -----
#THROUGHPUT IPC: 2.19126













