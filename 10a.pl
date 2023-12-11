#!/usr/bin/env perl
use v5.36;
use List::MoreUtils qw(firstidx);
my %dirs=(R=>[1,0], U=>[0,-1], L=>[-1,0], D=>[0,1]);
my @tiles=qw(JRUDL -RRLL 7RDUL |UUDD FURLD LLUDR s .);
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
my $step;
my $tile;
# find and take first step
for(qw(R U L D)){
    my $dir=$dirs{$_};
    my $next_coords = add($current_coords, $dir);
    $tile=tile($next_coords);
    my $next_step=$map{$tile}{$_};
    $current_coords=$next_coords, $step=$_, last if defined $next_step;
}
my $length=1;
# Notice step is out of phase with coords
while($tile ne "S"){
    $step=$map{$tile}{$step};
    die "Shouldn't happen" unless defined $step;
    my $dir=$dirs{$step};
    $current_coords = add($current_coords, $dir);
    $tile=tile($current_coords);
    ++$length;
}
say $length/2;


sub tile($p){
    my @p=@$p;
    return $sketch[$p[1]][$p[0]];
}
sub add($p, $q){
    return [map {$p->[$_]+ $q->[$_]}(0,1)];
}
