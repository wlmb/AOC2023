#!/usr/bin/env perl
use v5.36;
use List::AllUtils;
use PDL;
my %directions=(D=>pdl([0,1]), L=>pdl([-1,0]), U=>pdl([0,-1]), R=>pdl([1,0]));
my %opposite=(D=>"U", L=>"R", U=>"D", R=>"L");
my %follow=(D=>[qw(D L R)], L=>[qw(D L U)], U=>[qw(L U R)], R=>[qw(D U R)]);
my @map;
prepare_map();
my $height=@map;
my $width=$map[0]->@*;
my $corner=pdl($width-1, $height-1);
my ($startx, $endx)=map {List::AllUtils::firstidx {$_ eq "."} $_->@*} ($map[0], $map[-1]);
my ($start, $end)=(pdl($startx, 0), pdl($endx, $height-1));
my @graph=get_roads(); # [from, dir, to, dir, distance]
my %tmp;
$tmp{"$_->[0];$_->[2];$_->[4]"}=1 for @graph; # eliminate unnecesary roads.
my %graph;
push $graph{"$_->[0]"}->@*, ["$_->[1]", $_->[2]]
    for map {my @t=split ";"; [pdl($t[0]),pdl($t[1]), $t[2]]}keys %tmp; # from=>[[to, distance],...]
my %seen;
my $distance = compute_distance({%graph}, "$start", "$end", {%seen});
say $distance;

sub compute_distance($graph, $start, $end, $seen){
    my %graph=%$graph;
    my %seen=%$seen;
    return 0 if $start eq $end;
    return "-Inf" if $seen{$start};
    $seen{$start}=1;
    my @distances;
    for($graph{$start}->@*){
	my ($next, $distance)= @$_;
	push @distances, $distance+compute_distance($graph, $next, $end, {%seen});
    }
    my $max=List::AllUtils::max @distances;
    $max//="-Inf";
    return $max;
}

sub get_roads(){
    my @pending_road;
    push @pending_road, [$start, "D"]; # position and starting direction
    my @graph;
    my %tried_roads;
    while(@pending_road){
	my ($start, $direction)=(shift @pending_road)->@*;
	next if $tried_roads{"$start $direction"};
	$tried_roads{"$start $direction"}=1;
	my $path=singlepath($start,$direction); # end, distance, direction
	next unless defined $path;
	my ($end, $direction_end, $distance)=@$path;
	push @graph, [$start, $direction, $end, $_, $distance] for $follow{$direction_end}->@*;
	push @pending_road, [$end, $_] for $follow{$direction_end}->@*;
    }
    return @graph;
}

sub prepare_map(){
    while(<>){ # read
	chomp;
	last if /^\s*$/;
	push @map, [split "", $_];
    }
}

sub singlepath($start, $direction){
    my @pending;
    my $distance=0;
    my $current=$start;
    my ($x, $y)=$current->dog;
    $current=$current+$directions{$direction};
    while(1){
	return unless test($current);
	my ($x, $y)=$current->dog;
	++$distance;
	my $nwaysout=0;
	my $wayout;
	my @next=$follow{$direction}->@*;
	for(@next){
	    next if $_ eq $opposite{$direction}; # don't turn back if directed by slide
	    next unless test($current+$directions{$_});
	    ++$nwaysout;
	    $wayout=$_;
	}
	return [$current, $direction, $distance] if $nwaysout>1; #found branching node
	return [$current, $direction, $distance] if $nwaysout==0; #nowhere to go. end
	$direction=$wayout;
	$current=$current+$directions{$direction};
	($x,$y)=$current->dog;
    }
}

sub test($r){
    return 0 if (($r<0) | ($r>$corner))->orover; # don't leave map
    my ($x,$y)=$r->dog;
    return 0 if $map[$y][$x] eq "#"; # don't enter forest
    return 1;
}
