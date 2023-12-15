#!/usr/bin/env perl
use v5.36;
use Memoize;
memoize("howmany");
my $total=0;
my $copies=5;
while(<>){
    chomp;
    my ($record,$duplicate)=split " ";
    $record=join "?", (("$record") x $copies); # unfold
    $record.="."; # add guard
    $record=~s/\.+/./; # shorten separators
    $duplicate=join ",", (("$duplicate") x $copies);
    my @ndamaged=split ",", $duplicate;
    my $count=howmany($record, @ndamaged);
    $total += $count;
}
say $total;

sub howmany($record, @ndamaged){
    my $count=0;
    return $record=~/#/?0:1 unless @ndamaged;
    my $damaged=shift @ndamaged;
    while($record && $record=~s/^[^#]*?([?#]{$damaged}[^#])//){
	my $matched=$1;
	my $found = howmany($record, @ndamaged);
	$count += $found;
	last if $matched=~/^#/;
	$matched=~s/^.//; #shorten next record
	$record=$matched.$record;
    }
    return $count;
}
