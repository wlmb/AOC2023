#!/usr/bin/env perl
use v5.36;
my $symbol=qr([^\.\d]);
my @schematic;
my @valid; # valid sites
my $width;
while(<>){
    chomp;
    my @row=(".", split(""), ".");  # add left, right boundaries
    $width//=@row;
    die "Equal length lines expected" unless $width==@row;
    push @schematic, [@row];
    push @valid, [(0) x $width];
}
push @schematic, [(".") x $width];  # add initial, final boundaries
unshift @schematic, [(".") x $width];
push @valid, [(0) x $width];
unshift @valid, [(0) x $width];
for my $i(1..@schematic-2){
    for my $j(1..$width-2){
	next unless $schematic[$i][$j]=~/$symbol/;
	for my $k(-1,0,1){     # validate neighbors of symbols
	    for my $l(-1,0,1){
		$valid[$i+$k][$j+$l]=1;
	    }
	}
    }
}
my $total=0;
for my $i(1..@schematic-2){
    my @row=@{$schematic[$i]};
    my @valid_row=@{$valid[$i]};
    my $number=0;
    my $valid=0;
    for my $j(1..$width-2){
	$valid||=$valid_row[$j], $number=10*$number+$row[$j], next if $row[$j]=~/\d/;
	$total+=$number if $valid;
	$number=0;
	$valid=0
    }
    $total+=$number if $valid;
    $number=0;
    $valid=0;
}
say $total;
