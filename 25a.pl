#!/usr/bin/env perl
use v5.36;
my @deleted=qw(mhb zqg sjr jlt fjn mzb);
#my @deleted=qw(hfx pzl bvb cmg nvd jqt);
my %deleted=(@deleted, reverse @deleted);
my %connections;
while(<>){
    chomp;
    last if /^\s*$/;
    my @components=split /:?\s+/;
    my $first=shift @components;
    for(@components){
	next if defined $deleted{$first} and $deleted{$first} eq $_ ;
	push $connections{$first}->@*, $_;
	push $connections{$_}->@*, $first;
    }
 }
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
	push @pending, $_ for $connections{$current}->@*;
    }
    push @counts, $count;
}
say $counts[0]*$counts[1];
