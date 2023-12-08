#!/usr/bin/env perl
use v5.36;
use List::Util qw(all sum0 first);
my @cards=qw(2 3 4 5 6 7 8 9 T J Q K A);
my %value;
$value{$cards[$_]}=$_ for 0..@cards-1;
my @games=([1,1,1,1,1], [2,1,1,1], [2,2,1], [3,1,1], [3,2], [4,1], [5]);
my @hands;
while(<>){
    chomp;
    my($hand, $bid)=split " ";
    my $score=score(card_numbers($hand));
    my $values=[map {$value{$_}} split "", $hand];
    push @hands, [$hand, $bid, $score, $values];
}
my @sorted=sort {by_hand($a, $b) || by_cards($a, $b)} @hands;
my $result= sum0 map {($_+1)*$sorted[$_][1]} 0..@sorted-1;
say $result;

sub by_hand {
    my $cmp= $a->[2] <=> $b->[2];
    return $cmp;
}

sub by_cards {
    my ($va, $vb)=map {$_->[3]} ($a, $b);
    my $cmp=first {$_} map {$va->[$_] <=> $vb->[$_]} (0..@$va-1);
    return $cmp//0;
}

sub card_numbers($h){
    my %m;
    ++$m{$_} for split "", $h;
    return [sort {$b<=>$a} values %m];
}

sub score($c){
    my $nc=@$c;
    for(0..@games-1){
	my $g=$games[$_];
	my $ng=@$g;
	next unless $ng==$nc;
	return $_ if all {$g->[$_] eq $c->[$_]} 0..$ng-1;
    }
    die "Shouldn't reach";
}
