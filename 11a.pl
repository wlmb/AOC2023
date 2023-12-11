#!/usr/bin/env perl
use v5.36;
use PDL;
use PDL::NiceSlice;
use Algorithm::Combinatorics qw(combinations);
my @universe;
while(<>){
    chomp;
    s/\./0/g;
    s/\#/1/g;
    my $r=pdl split "";
    push @universe, $r;
}
my $universe=pdl(@universe);
my $zero_row=$universe(:,(0))->zeroes;
my @universe_yexpanded;
for(@universe){
    push @universe_yexpanded, $_;
    push @universe_yexpanded, $_ if ($_==0)->all;
}
my $universe_yexpanded=pdl(@universe_yexpanded);
my @universe_xyexpanded;
for($universe_yexpanded->transpose->dog){
    push @universe_xyexpanded, $_;
    push @universe_xyexpanded, $_ if ($_==0)->all;
}
my $universe_expanded=pdl(@universe_xyexpanded)->transpose;
my $galaxies=$universe_expanded->whichND;
my $galaxy_pairs=combinations([$galaxies->dog], 2);
my $sum=0;
while(my $g=$galaxy_pairs->next){
    my $r=pdl($g);
    $sum+=($r(:,(1))-$r(:,(0)))->abs->sumover;
}
say $sum;
