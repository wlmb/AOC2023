#!/usr/bin/env perl
use v5.36;
use List::Util qw(all sum0 first);
my @cards=qw(J 2 3 4 5 6 7 8 9 T Q K A);
my %value_cards;
$value_cards{$cards[$_]}=sprintf "%02d", $_ for 0..@cards-1;
my @games=(11111, 2111, 221, 311, 32, 41, 5);
my @hands;
while(<>){
    chomp;
    my($hand, $bid)=split " ";
    my $score=card_numbers($hand);
    my $values=join "", map {$value_cards{$_}} split "", $hand;
    push @hands, [$hand, $bid, $score, $values];
}
my @sorted=sort {$a->[2] cmp $b->[2] || $a->[3] cmp $b->[3]} @hands;
my $result= sum0 map {($_+1)*$sorted[$_][1]} 0..@sorted-1;
say $result;

sub card_numbers($h){
    my %m;
    ++$m{$_} for split "", $h;
    my @sorted=sort {$m{$b}<=>$m{$a}} keys %m;
    for(0..@sorted-1){
	if($sorted[$_] eq "J"){
	    my $add=$m{"J"};
	    if(@sorted>1){ # if other cards
		splice @sorted, $_, 1; # add J to others
		$m{$sorted[0]} += $add;
	    }
	    last;
	}
    }
    return join "", map {$m{$_}} @sorted;
}
