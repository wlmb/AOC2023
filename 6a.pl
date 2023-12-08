#!/usr/bin/env perl
use v5.36;
use POSIX qw(floor ceil);
chomp(my $times=<>);
die "Bad times" unless $times=~s/^\s*Time:\s*(.*)\s*$/$1/i;
my @times=split " ", $times;
chomp(my $distances=<>);
die "Bad distances" unless $distances=~s/^\s*Distance:\s*(.*)\s*/$1/i;
my @distances=split " ", $distances;
die "Wrong dimensions" unless @times==@distances;
my $total=1;
for(0..@times-1){
    my $t=$times[$_];
    my $x=$distances[$_];
    my $s=sqrt($t**2-4*$x);
    my $v0=ceil(($t-$s)/2);
    my $v1=floor(($t+$s)/2);
    my $ways=$v1-$v0+1;
    $ways-=2 if $s==floor($s);
    $total*=$ways;
}
say $total;
