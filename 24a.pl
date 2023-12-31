#!/usr/bin/env perl
use v5.36;
use PDL;
#use PDL::LinearAlgebra;
#use PDL::MatarixOps;
# assume min, max and filename in @ARGV
die "Missing arguments" unless 2<=@ARGV<=3;
my $min=shift @ARGV;
my $max=shift @ARGV;
my @hailstones;
while(<>){
    chomp;
    last if /^\s*$/;
    my ($r, $v)=map {$_->slice([0,1])} map {pdl($_)} split /\s*@\s*/; #2D
    push @hailstones, [$r, $v];
}

my $count=0;
for my $i0(0..@hailstones-2){
    for my $i1($i0+1..@hailstones-1){
	my ($h0, $h1)=map {$hailstones[$_]} ($i0, $i1);
	my ($r0, $r1)=map {$_->[0]} ($h0, $h1);
	my ($v0, $v1)=map {$_->[1]} ($h0, $h1);
	my $m=pdl($v0, -$v1)->transpose;
	my $dr=($r1-$r0);
	my ($lu, $parm, $parity)=lu_decomp($m);
	my $det=det($m, {lu=>[$lu, $parm, $parity]});
	next if $det->approx(0);
	my $t=lu_backsub($lu, $parm, $parity, $dr);
	next unless ($t>=0)->all;
	my $r=$r0+$v0*$t->slice([0,0,0]);
	next unless (($r>=$min)&($r<=$max))->all;
	++$count;
    }
}
say $count;
