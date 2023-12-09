#!/usr/bin/env perl
use v5.36;
use PDL;
use PDL::NiceSlice;
my $total=0;
while(<>){
    chomp;
    $total += extrapolate(pdl($_));
}
say $total;

sub extrapolate($v){
    return 0 if ($v==0)->all;
    return $v->at(-1)+extrapolate($v(1:-1)-$v(0:-2));
}
