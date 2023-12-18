#!/usr/bin/env perl
use v5.36;
use List::Util qw(min);
my %steps=(">"=>[1,0], "^"=>[0,-1], "<"=>[-1,0], "v"=>[0,1]);
my %opposite=(">"=>"<", "^"=>"v", "<"=>">", "v"=>"^");
my @blocks;
while(<>){
    chomp;
    last if /^$/;
    push @blocks, [split ""];
}
my $height=@blocks;
my $width=$blocks[0]->@*;
my @cost;
my @pending;
push @pending, [$width, $height-1,">",0], [$width-1, $height,"v",0];
while(@pending){
    my ($x, $y, $dir, $cost)=(shift @pending)->@*;
    my $first=substr $dir,0,1;
    ($x, $y)=subtract([$x,$y], $steps{$first})->@*;
    next if $x<0 or $x>=$width or $y<0 or $y>=$height;
    my $current_cost=$cost[$y][$x];
    my $visited=defined $current_cost && defined $current_cost->{$dir};
    my $change=!$visited || $current_cost->{$dir}>$cost;
    next unless $change; # been here on better path
    $cost[$y][$x]{$dir}=$cost; # set new cost of path from here to end
    $cost+=$blocks[$y][$x]; # update cost

    for(keys %steps){
	my $next_dir = $_;
	$next_dir .= $dir if $next_dir eq $first; # consecutive steps
	next if length $next_dir > 3;
	next if $_ eq $opposite{$first};
	push @pending, [$x, $y, $next_dir, $cost]
    }
}
my @totals=values $cost[0][0]->%*;
my $total=min @totals;
say $total;

sub subtract($p, $q){
    return [map {$p->[$_]-$q->[$_]} 0..@$p-1];
}
