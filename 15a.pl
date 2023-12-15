#!/usr/bin/env perl
use v5.36;
my $total=0;
while(<>){
    chomp;
    for(split ","){
	my $hash=0;
	$hash = ($hash+ord)*17%256 for(split "");
	$total += $hash;
    }
}
say $total;
