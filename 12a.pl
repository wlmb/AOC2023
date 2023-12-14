#!/usr/bin/env perl
use v5.36;
use re qw(eval);
my $count=0;
while(<>){
    chomp;
    my ($condition,$duplicate)=split " ";
    my @nfails=split ",", $duplicate;
    my $re="^[.?]*" . join("[.?]+", map {"[?#]{$_}"} @nfails) . '[?.]*$(?{++$count})(*FAIL)';
    $condition=~/$re/;
}
say $count;
