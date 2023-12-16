#!/usr/bin/env perl
use v5.36;
my %mask=(right=>1,     up=>2,      left=>4,      down=>8);
my %steps=(right=>[1,0], up=>[0,-1], left=>[-1,0], down=>[0,1]);
my %next_dirs=(
    "." =>{right=>["right"],      up=>["up"],
	  left=>["left"],        down=>["down"]},
    "-" =>{right=>["right"],      up=>["right", "left"],
	  left=>["left"],        down=>["right", "left"]},
    "/" =>{right=>["up"],         up=>["right"],
	  left=>["down"],        down=>["left"]},
    "|" =>{right=>["up", "down"], up=>["up"],
	  left=>["up", "down"],  down=>["down"]},
    "\\"=>{right=>["down"],       up=>["left"],
	   left=>["up"],		 down=>["right"]}
    );


my @devices;
while(<>){
    chomp;
    push @devices, [split ""];
}
my $height=@devices;
my $width=$devices[0]->@*;
my @dirs=map {[(0) x $width]} 0..$height-1;
my @pending_beams;
push @pending_beams, [-1,0,"right"];
my $total;
while(@pending_beams){
    my ($x, $y, $dir)=(shift @pending_beams)->@*;
    ($x,$y)=add([$x,$y], $steps{$dir})->@*;
    next if $x<0 or $x>=$width or $y<0 or $y>=$height;
    my $dir_mask = $mask{$dir};
    next if $dirs[$y][$x] & $dir_mask;
    ++$total unless $dirs[$y][$x];
    $dirs[$y][$x] |= $dir_mask;
    my $device=$devices[$y][$x];
    my $next_dirs=$next_dirs{$device}{$dir};
    push @pending_beams, map{[$x, $y, $_]} $next_dirs->@*;
}
say $total;

sub add($p, $q){
    return [map {$p->[$_]+$q->[$_]} 0..@$p-1];
}
