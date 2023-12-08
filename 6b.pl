#!/usr/bin/env perl
use v5.36;
use POSIX qw(floor ceil);
chomp(my $t=<>);
die "Bad times" unless $t=~s/^\s*Time:\s*(.*)\s*$/$1/i;
chomp(my $x=<>);
die "Bad distances" unless $x=~s/^\s*Distance:\s*(.*)\s*/$1/i;
s/\s+//g for ($t, $x);
my $s=sqrt($t**2-4*$x);
my $v0=ceil(($t-$s)/2);
my $v1=floor(($t+$s)/2);
my $ways=$v1-$v0+1;
$ways-=2 if $s==floor($s);
say $ways;
