#!/usr/bin/env perl
use v5.36;
use List::Util qw(sum0);

die "Usage. $0 N file to relax N times" unless @ARGV==2;
my $Nrelax=shift;
my %connections;
while(<>){
    chomp;
    last if /^\s*$/;
    my @components=split /:?\s+/;
    my $first=shift @components;
    for(@components){
	push $connections{$first}->@*, $_;
	push $connections{$_}->@*, $first;
    }
}
my ($first, $last, $nodes)=search_diameter();
my %voltage;
my @nodes=@$nodes; # ordered from first to last
$voltage{$_}=0 for @nodes;
$voltage{$first}=1;
$voltage{$last}=-1;
relax() for (1..$Nrelax);
my %edges;
do {my $f=$_;do {my @s=sort($f, $_); $edges{"@s"}=abs($voltage{$f}-$voltage{$_})}
		 for $connections{$f}->@*} for @nodes;
my @edges=sort {$edges{$b} <=> $edges{$a}} keys %edges;
# test triads of edges until graph disconnects
my $Nedges=@edges;
my ($i, $j, $k)=(0,1,2);
while($k<$Nedges){
    last if disconnect(map {$edges[$_]} ($i, $j, $k));
    ++$i, next if $i+1<$j;
    ++$j, $i=0, next if $j+1<$k;
    ++$k, $i=0, $j=1;
}

sub relax(){
    my $voltage1;
    $voltage{$_}=sum0 (map {$voltage{$_}} $connections{$_}->@*)/$connections{$_}->@* for @nodes;
    $voltage{$last}=-1;
    $voltage{$_}=sum0(map {$voltage{$_}} $connections{$_}->@*)/$connections{$_}->@* for reverse @nodes;
    $voltage{$first}=1;
}

sub search_diameter(){
    my $start0=(keys %connections)[0]; #arbitrary starting site
    my $start=antipode($start0);
    my ($end, $nodes)=antipode($start);
    return ($start, $end, $nodes);
}
sub antipode($start){
    my @pending;
    my %visited;
    push @pending, $start;
    my $last;
    my @nodes;
    while(@pending){ # search farthest from $start0 breath first search
	my $current=shift @pending;
	next if $visited{$current};
	$visited{$current}=1;
	push @nodes, $current;
	$last=$current;
	push @pending, $connections{$current}->@*;
    }
    return wantarray? ($last, [@nodes]):$last;
}

sub disconnect($p, $q, $r){
    # try to disconnect graph by removing edges $p, $q and $r
    my @deleted=map {split " "} ($p, $q, $r);
    my %deleted=(@deleted, reverse @deleted);
    my $group1=$deleted[0];
    my $group2=$deleted[1];
    my @counts;
    for($group1, $group2){
	my %visited;
	my @pending;
	push @pending, $_;
	my $count=0;
	while(@pending){
	    my $current=shift @pending;
	    next if $visited{$current};
	    ++$count;
	    $visited{$current}=1;
	    #$visited{$_} || push @pending, $_ for $connections{$current}->@*;
	    push @pending, $_
		for grep {!($deleted{$current} && $deleted{$_})} $connections{$current}->@*;
	}
	return 0 if $count==@nodes; # didn't split
	push @counts, $count;
    }
    say "$p $q $r ", $counts[0]*$counts[1];
}
