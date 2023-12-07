#!/usr/bin/env perl
use v5.36;
my $total=0;
while(<>){
    chomp;
    die unless /.*:\s*(.*)\s*\|\s*(.*)\s*/;
    my @winning=split " ", $1;
    my @mine=split " ", $2;
    my %winning;
    $winning{$_}=1 for @winning;
    my $matches=0;
    $winning{$_} && ++$matches for(@mine);
    my $score=0;
    $score=1<<($matches-1) if $matches;
    $total += $score;
}
say $total;
