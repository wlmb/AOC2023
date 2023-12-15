#!/usr/bin/env perl
use v5.36;
use List::Util qw(all min);
local $/=""; # paragraph at a time
my $total=0;
while(<>){
    my @rows=split /^/;
    pop @rows if $rows[-1]=~/^$/; # remove empty line
    chomp for @rows;
    my $width=length $rows[0];
    my $height=@rows;
    my @cols;
    for (0..@rows-1){
	my @row=split "", $rows[$_];
	$cols[$_].=$row[$_] for 0..$width-1;
    }
    my @horizontal=search_mirror(@rows);
    my @vertical=search_mirror(@cols);
    $total+=($_+1)*100 for @horizontal;
    $total+=$_+1 for @vertical;
}
say $total;

sub search_mirror(@arr){ # search mirror plane
    my $N=@arr;
    my @c;
    for my $c(0..$N-2){
	my $m=min($c, $N-2-$c);
	push @c, $c if all {$arr[$c-$_] eq $arr[$c+1+$_]} (0..$m);
    }
    return @c;
}
