#!/usr/bin/env perl
use v5.36;
use List::Util qw(sum0);
my @scores;
while(<>){
    chomp;
    die unless /.*:\s*(.*)\s*\|\s*(.*)\s*/;
    my @winning=split " ", $1;
    my @mine=split " ", $2;
    my %winning;
    $winning{$_}=1 for @winning;
    my $matches=0;
    $winning{$_} && ++$matches for(@mine);
    push @scores, $matches;
}
my @cards=(1) x @scores;
for(0..@scores-1){
    my $multiplier=$cards[$_];
    $cards[$_] += $multiplier for ($_+1..$_+$scores[$_]);
}
my $cards=sum0 @cards;
say $cards;
