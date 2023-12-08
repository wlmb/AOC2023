#!/usr/bin/env perl
use v5.36;
use List::Util qw(all);
use Math::Prime::Util qw(lcm);
chomp(my $instructions=<>);
my @instructions=split "", $instructions;
my $num_instructions=@instructions;
my %node;
chomp(my $space=<>);
die "Bad format" unless $space=~/^\s*$/;
my @start;
my %end;
while(<>){
    /(\w{3})\s*=\s*\((\w{3})\,\s*(\w{3})\s*\)$/
    or die "Bad format";
    my ($f, $l, $r)=($1, $2, $3);
    die if defined $node{$f};
    $node{$f}{L}=$l;
    $node{$f}{R}=$r;
    push @start, $f if $f=~/A$/;
    $end{$f}=1  if $f=~/Z$/;
}
die "Missing start" unless @start;
# Find cycle lengths
my @cycles;
for (@start){
    my $current=$_;
    my $t=0;
    $current=$node{$current}{instruction($t++)} while(!$end{$current});
    push @cycles, $t;
}
my $length= lcm(@cycles);
say $length;

sub instruction($step){
    $instructions[$step%$num_instructions];
}
