#!/usr/bin/env perl
use v5.36;
use List::Util qw(min);
local $/=""; # paragraph at a time
my %exchange=("."=>"#", "#"=>".");
my $total=0;
while(<>){
    my @rows=split /^/;
    pop @rows if $rows[-1]=~/^$/; # remove empty line
    chomp for @rows;
    my $width=length $rows[0];
    my $height=@rows;
    my @sketch;
    push @sketch, [split "", $_] for @rows;
    my $h=analyze(@sketch);
    my $v=analyze(transpose(@sketch));
    $total+=100*$h+$v;
}
say $total;

sub analyze(@arr){ # search mirror planes
    my $height=@arr;
    my $width=@{$arr[0]};
    for my $r(0..$height-2){ # for each possible mirror
	my $errs; # number of errors
	my $m=min($r, $height-2-$r);
	for(0..$m){ # for each object-image pair
	    for my $c(0..$width-1){
		my $diff=$arr[$r-$_][$c] ne $arr[$r+1+$_][$c];
		$errs+=$diff;
	    }
	}
	return $r+1 if($errs==1); #assume only one mirror with exactly one smudge
    }
    return 0;
}

sub transpose(@arr){
    my @res;
    return @res unless @arr;
    my $height=@arr;
    my $width=@{$arr[0]} if $height;
    for my $i(0..$height-1){
	for my $j(0..$width-1){
	    $res[$j][$i]=$arr[$i][$j];
	}
    }
    return @res;
}
