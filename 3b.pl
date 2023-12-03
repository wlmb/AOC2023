#!/usr/bin/env perl
use v5.36;
my $gear=qr(\*);
my @schematic;
my @parts;
my $width;
while(<>){
    chomp;
    my @row=(".", split(""), ".");  # add left, right boundaries
    $width//=@row;
    die "Equal length lines expected" unless $width==@row;
    my $number;
    for(@row){
	if(/\d/){
	    $number//=0;
	    $number=10*$number+$_;
	    $_=@parts; # part index
	}else{
	    push @parts, $number if defined $number;
	    undef $number;
	}
    }
    push @schematic, [@row];
}
push @schematic, [(".") x @{$schematic[0]}];  # add initial, final boundaries
unshift @schematic, [(".") x @{$schematic[0]}];
my $total=0;
for my $i(1..@schematic-2){
    for my $j(1..$width-1){
	next unless $schematic[$i][$j]=~/$gear/;
	my %neighbors;
	for my $k(-1,0,1){
	    for my $l(-1,0,1){
		$neighbors{$schematic[$i+$k][$j+$l]}=1 if $schematic[$i+$k][$j+$l]=~/\d/;
	    }
	}
	my @neighbors=keys %neighbors;
	next unless @neighbors==2; # exactly two neighbors
	$total+=$parts[$neighbors[0]]*$parts[$neighbors[1]];
    }
}
say $total;
