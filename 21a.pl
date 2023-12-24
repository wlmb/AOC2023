#!/usr/bin/env perl
use v5.36;
use PDL;
use List::Util qw(sum0);
use bigint;
my @dirs=map {pdl $_} ([0,1],[1,0],[-1,0],[0,-1]);
my $start;
my $N=64;
my %type;
my $y=0;
my $xmax;
while(<>){
    chomp;
    my @line=split "";
    $xmax//=@line;
    my $x=0;
    for(@line){
	my $coords=pdl[$y,$x];
	$type{$coords}=/S/?0:$_;
	$start=$coords if(/S/);
	++$x;
    }
    ++$y;
}
my $ymax=$y;
my $tl=pdl[0,0];
my $br=pdl[$ymax,$xmax];
my @pending;
my @next_pending;
push @pending, $start;
for(1..$N){
    my $parity=$_%2;
    while(@pending){
	my $current=shift @pending;
	for(@dirs){
	    my $coords=$current+$_;
	    next unless ($coords>=$tl)->all && ($coords<$br)->all;
	    push(@next_pending, $coords), $type{$coords}=$parity if $type{$coords} eq ".";
	}
    }
    @pending=@next_pending;
    @next_pending=();
}
my $final_parity=$N%2;
my $count=sum0 map {~~($type{$_} eq $final_parity)} keys %type;
say "$count";
