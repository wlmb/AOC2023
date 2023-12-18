#!/usr/bin/env perl
use v5.36;
use PDL;
use PDL::NiceSlice;
my %dirs=(R=>pdl(1,0), U=>pdl(0,-1), L=>pdl(-1,0), D=>pdl(0,1));
my $first=my $current=pdl(0,0);
my @border=($first);
my @edges;
while(<>){
    chomp;
    last if /^$/;
    die "Wrong input" unless /([RULD])\s+(\d*)\s+\((#[0-9a-f]{6})\)/;
    my ($dir, $dist, $color)=($1, $2, $3);
    $current= $current+(my $edge=$dist*$dirs{$dir});
    push @border, $current;
    push @edges, $edge;
}
die "Not a cycle" unless ($current==$first)->all;
my $border=pdl(@border);
my $perimeter=pdl(@edges)->abs->sumover->sumover;
my $area=cross($border(:,0:-2), $border(:,1:-1))->sumover->abs/2;
my $result=$area+$perimeter/2+1;
say $result;


sub cross($p, $q){
    return pdl($p((0))*$q((1))-$p((1))*$q((0)));
}
