#!/usr/bin/env perl
use v5.36;
use PDL;
use List::Util;
my @bricks;
my @overlap;
my @underlap;
my @supports;
my @supported_by;
while(<>){ # read
    chomp;
    my ($first, $last)=map {pdl($_)} split "~";
    die "Bad ordere" unless ($last>=$first)->all;
    push @bricks, pdl($first, $last);
}
@bricks=sort {$a->slice([2,0,0],[0,0,0]) <=> $b->slice([2,0,0],[0,0,0])
#		  && $a->slice([2,0,0],[1,0,0]) <=> $b->slice([2,0,0],[1,0,0])
} @bricks;
for my $l(0..@bricks-1){ #find overlaps
    for my $u ($l+1..@bricks-1){
	my ($lower, $upper)=map {$bricks[$_]}($l, $u);
	my $overlap=overlap($lower, $upper);
	next unless defined $overlap;
	($l, $u)=($u, $l), ($lower, $upper)=($upper, $$lower)
	    if $lower->slice([2,0,0],[1,0,0])>$upper->slice([2,0,0],[0,0,0]);
	die "Fishy $bricks[$l] $bricks[$u]" # no vertical overlap if horizontal overlap
	    if $bricks[$l]->slice([2,0,0],[1,0,0])>$bricks[$u]->slice([2,0,0],[0,0,0]);
	push $overlap[$l]->@*, $u; #[$u, $overlap];
	push $underlap[$u]->@*, $l; #[$l, $overlap];
    }
}
for my $b(0..@bricks-1){ #settle down
    my $height=1+ # height of underbricks
	((List::Util::max map {$bricks[$_]->slice([2,0,0],[1,0,0])} $underlap[$b]->@*)//-1);
    my $fall = $bricks[$b]->slice([2,0,0],[0,0,0])-$height;
    $bricks[$b]->slice(2)-=$fall;
}
for my $b(0..@bricks-1){ #set who supports whom
    for my $s($underlap[$b]->@*){
	push($supported_by[$b]->@*, $s),
	    push($supports[$s]->@*, $b) if $bricks[$s]->slice(2,1)+1==$bricks[$b]->slice(2,0);
    }
}
my $count=0;
for my $b(0..@bricks-1){ #count removable bricks
    ++$count, next unless defined $overlap[$b] && $overlap[$b]->@*; # no brick above
    ++$count, next unless defined $supports[$b] && $supports[$b]->@*; # supports none
    ++$count, next if pdl(map {~~($supported_by[$_]->@* >= 2)}  $supports[$b]->@*)->all;
}
say $count;


use PDL::NiceSlice;
sub overlap($l, $u){
    my $both=pdl($l(0:1),$u(0:1)); # xy, corner, brick
    my ($min,$max)=($both->mv(-1,0)->minover, $both->mv(-1,0)->maxover); #xy, corner
    my $corners=pdl($max(:,(0)), $min(:, (1))); #xy, corner
    return $corners if ($corners(:,0)<=$corners(:,1))->all;
    return;
}
no PDL::NiceSlice;
