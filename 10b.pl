#!/usr/bin/env perl
use v5.36;
use List::MoreUtils qw(firstidx);
my %dirs=(R=>[1,0], U=>[0,-1], L=>[-1,0], D=>[0,1]);
my @tiles=qw(JRUDL -RRLL 7RDUL |UUDD FURLD LLUDR S .);
my %map=map {my @t=split ""; @t==5?($t[0]=>{$t[1]=>$t[2], $t[3]=>$t[4]}):()} @tiles;
my @sketch;
my $row=0;
my $current_coords;
while(<>){
    chomp;
    my @row=split "";
    push @sketch, [@row];
    my $col = firstidx {$_ eq "S"} @row;
    $current_coords=[$col,$row] if $col >= 0;
    ++$row;
}
die "No initial tile" unless defined $current_coords;
my %in_path;
my $step;
my $tile;
# find and take first step
for(qw(U R D L)){
    my $dir=$dirs{$_};
    my $next_coords = add($current_coords, $dir);
    $tile=tile($next_coords);
    my $next_step=$map{$tile}{$_};
    if(defined $next_step){
	$in_path{"@$current_coords"}=1;
	$current_coords=$next_coords;
	$step=$_;
	last;
    }
}
my $first_step=$step;
# Notice step is out of phase, behind coords and tile
while($tile ne "S"){
    $step=$map{$tile}{$step};
    die "Shouldn't happen" unless defined $step;
    $in_path{"@$current_coords"}=1;
    my $dir=$dirs{$step};
    $current_coords = add($current_coords, $dir);
    $tile=tile($current_coords);
}
my $last_step=$step;
my ($start_x, $start_y)=@$current_coords;
for(keys %map){ # replace starting symbol by correct tile
    next unless defined $map{$_} && defined $map{$_}{$last_step};
    $sketch[$start_y][$start_x]=$_, last if $map{$_}{$last_step} eq $first_step;
}

my $height=@sketch;
my $width=$sketch[0]->@*;
my $count=0;
for my $y (0..$height-1){
    my $odd=0;
    my $enter="";
    my $local_count=0;
    for my $x (0..$width-1){
	my $tile=tile([$x,$y]);
	if($in_path{"$x $y"}){
	    $enter=$tile if $tile=~/[FL]/;
	    $odd=!$odd
		if $tile eq "|"
		or $enter eq "F" and $tile eq "J"
		or $enter eq "L" and $tile eq "7";
	    $enter="" if $tile=~/[J7]/;
	    $count += $local_count;
	    $local_count=0;
	}else{
	    ++$local_count if $odd;
	}
    }
}

say $count;

sub tile($p){
    my @p=@$p;
    return $sketch[$p[1]][$p[0]];
}
sub add($p, $q){
    return [map {$p->[$_]+ $q->[$_]}(0,1)];
}
