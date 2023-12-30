#!/usr/bin/env perl
use v5.36;
use List::AllUtils;
use PDL;
my %directions=(D=>pdl([0,1]), L=>pdl([-1,0]), U=>pdl([0,-1]), R=>pdl([1,0]));
my %opposite=(D=>"U", L=>"R", U=>"D", R=>"L");
my %follow=(D=>[qw(D L R)], L=>[qw(D L U)], U=>[qw(L U R)], R=>[qw(D U R)]);
my %slides=("v"=>"D", "<"=>"L", "^"=>"U", ">"=>"R");
my @map;
prepare_map();
my $height=@map;
my $width=$map[0]->@*;
my $corner=pdl($width-1, $height-1);
my ($startx, $endx)=map {List::AllUtils::firstidx {$_ eq "."} $_->@*} ($map[0], $map[-1]);
my ($start, $end)=(pdl($startx, 0), pdl($endx, $height-1));
my @graph=get_roads(); # [from, to, distance]
my %graph;
push $graph{"$_->[0]"}->@*, ["$_->[1]", $_->[2]] for @graph; # from=>[[to, distance],...]
my $distance = compute_distance({%graph}, "$start", "$end");
say $distance;

sub get_roads(){
    my @pending_road;
    push @pending_road, [$start, $_] for keys %directions; # position and starting direction
    my @graph;
    my %tried_roads;
    while(@pending_road){
	my ($current, $direction)=(shift @pending_road)->@*;
	next if $tried_roads{"$current $direction"};
	$tried_roads{"$current $direction"}=1;
	my $edge=singlepath($current,$direction); # start, end, distance
	next unless defined $edge;
	push @graph, $edge;
	my ($x1, $y1)=(my $end=$edge->[1])->dog;
	do {push @pending_road, [$end, $_] for keys %directions}
	unless List::AllUtils::all {$map[$y1][$x1] eq $_} keys %slides;
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

sub compute_distance($graph, $start, $end){
    my %graph=%$graph;
    my @sorted=sort_nodes(%graph);
    my %distance;
    $distance{$_}="-Inf" for @sorted;
    $distance{$end}=0;
    for my $s(@sorted){
	for($graph{$s}->@*){
	    $distance{$s}=List::AllUtils::max ($distance{$s}, $distance{$_->[0]}+$_->[1]);
	}
    }
    return $distance{"$start"};
}

sub sort_nodes(%graph){
    my %seen;
    my @sorted;
    my @pending=keys %graph;
    while(@pending){
	my $current=pop @pending;
	next if $seen{$current};
	my $next=$graph{$current}; # start
	push(@sorted, $current), $seen{$current}=1, next unless defined $next && @$next; # end node
	my @additional= grep {!$seen{$_}} map {$_->[0]} @$next;
	push(@pending, $current, @additional), next if @additional;
	$seen{$current}=1;
	push(@sorted, $current);
    }
    return @sorted;
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
	my $slide=$slides{$map[$y][$x]};
	my @next=defined $slide?($slide): $follow{$direction}->@*;
	for(@next){
	    next if $_ eq $opposite{$direction}; # don't turn back if directed by slide
	    next unless test($current+$directions{$_});
	    ++$nwaysout;
	    $wayout=$_;
	}
	return [$start, $current, $distance] if $nwaysout>1; #found branching node
	return if slide_at($current) && $nwaysout==0; # don't allow paths ending at slides
	return [$start, $current, $distance] if $nwaysout==0; #nowhere to go. end
	$direction=$wayout;
	$current=$current+$directions{$direction};
	($x,$y)=$current->dog;
    }
}

sub slide_at($r){
    my ($x, $y)=$r->dog;
    return $slides{$map[$y][$x]};
}

sub test($r){
    return 0 if (($r<0) | ($r>$corner))->orover; # don't leave map
    my ($x,$y)=$r->dog;
    return 0 if $map[$y][$x] eq "#"; # don't enter forest
    return 1;
}
