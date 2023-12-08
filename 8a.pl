#!/usr/bin/env perl
use v5.36;
chomp(my $instructions=<>);
my @instructions=split "", $instructions;
sub next_move() {
    my $move=shift @instructions;
    push @instructions, $move;
    return $move;
}
my %node;
chomp(my $space=<>);
die "Bad format" unless $space=~/^\s*$/;
while(<>){
    /(\w{3})\s*=\s*\((\w{3})\,\s*(\w{3})\s*\)$/
    or die "Bad format";
    my ($f, $l, $r)=($1, $2, $3);
    die if defined $node{$f};
    $node{$f}{L}=$l;
    $node{$f}{R}=$r;
}
die "Missing start" unless defined $node{AAA};
my $current="AAA";
my $steps=0;
while($current ne "ZZZ"){
    ++$steps;
    die "Missing node" unless defined $node{$current};
    $current=$node{$current}{next_move()}
}
say $steps;
