#!/usr/bin/env perl
use v5.36;
use v5.36;
my $factor=1000000; # expansion factor
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
my $galaxies=$universe->whichND; # get coordinates of galaxies
my $expansion_x=(!$universe->transpose->orover)->which;
my $expansion_y=(!$universe->orover)->which;
my $xcoords=sequence($universe->dim(0));
for($expansion_x->dog){
    $xcoords($_:-1)+=$factor-1;
}
my $ycoords=sequence($universe->dim(1));
for($expansion_y->dog){
    $ycoords($_:-1)+=$factor-1;
}
my $galaxy_pairs=combinations([$galaxies->dog], 2);
my $sum=0;
while(my $g=$galaxy_pairs->next){
    my($r0, $r1)=map{pdl($_)}@$g;
    for($r0, $r1){
	$_(0).=$xcoords($_((0)));
	$_(1).=$ycoords($_((1)));
    }
    $sum+=($r1-$r0)->abs->sumover;
}
say $sum;
