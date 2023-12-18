#!/usr/bin/env perl
use v5.36;
use List::Util qw(min);
my $min_length=4;
my $max_length=10;
my %steps=(">"=>[1,0], "^"=>[0,-1], "<"=>[-1,0], "v"=>[0,1]);
my @dirs=sort keys %steps;
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
$cost[$height-1][$width-1]={"", 0};
my @pending;
push @pending, map{[$width-$_->[0], $height-$_->[1],$_->[2],
		    $blocks[$height-1][$width-1]]}
                    ([2,1,">"], [1,2,"v"]);
my $iterations=0;
while(@pending){
    ++$iterations;
    my ($x, $y, $dir, $cost)=(shift @pending)->@*;
    my $first=substr $dir,0,1;
    next if $x<0 or $x>=$width or $y<0 or $y>=$height;
    my $current_cost=$cost[$y][$x];
    my $visited=defined $current_cost && defined $current_cost->{$dir};
    my $change=!$visited || $current_cost->{$dir}>$cost;
    next unless $change; # been here on better path
    $cost[$y][$x]{$dir}=$cost; # set new cost of path from here to end
    $cost+=$blocks[$y][$x]; # update cost

    #    for(keys %steps){
    for(@dirs){
	my $next_dir = $_;
	$next_dir .= $dir if $next_dir eq $first; # consecutive steps
	next if length $next_dir > $max_length; # don't turn late
	next if $_ eq $opposite{$first};
	next if $_ ne $first and length $dir < $min_length; # don't turn early
	my ($nx,$ny)=subtract([$x,$y], $steps{$_})->@*;
	push @pending, [$nx, $ny, $next_dir, $cost]
    }
}
my %totals=$cost[0][0]->%*;
my @totals=map {
    $totals{$_}
} grep {length $_ >= $min_length && length $_ <=$max_length}
keys %totals;
my $total=min @totals;
say $total;
#for(keys %totals){
#    say "$totals{$_} $_";
#}


sub subtract($p, $q){
    return [map {$p->[$_]-$q->[$_]} 0..@$p-1];
}
