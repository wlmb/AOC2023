#!/usr/bin/env perl
use v5.36;
use PDL;
my $Nstones=3;
my $err=0.01;
my @hailstones;
while(<>){
    chomp;
    last if /^\s*$/;
    my ($r, $v)=map {pdl($_)} split /\s*@\s*/; #2D
    push @hailstones, [$r, $v];
}

#organize the unknowns as a vector R, V and t
#call the indices cr, cv and h. the cartesian without distinction are c
# first guess
my $R=zeroes(3); # cr
#my $V=zeroes(3)+1; # cr
my $V=sequence(3)*10; # cr
#my $t=zeroes(3); # h
my $t=pdl(1,2,3); # 012 test

my $r=pdl(map {$_->[0]} @hailstones[0..$Nstones-1]); #cr,h
my $v=pdl(map {$_->[1]} @hailstones[0..$Nstones-1]); #cv,h
while(1){  # Newton's iteration
    my $rhs=-($R-$r # c, h
	      +($V - $v)*$t->dummy(0) # c,h
	)->reshape(3*$Nstones); #c*h
    my $id3=identity(3);
    my $MR=$id3->dummy(2,$Nstones) #cr,cr,h
	->reshape(3, 3*$Nstones);   #cr cr*h
    my $MVt=($id3->dummy(2,$Nstones)*$t->dummy(0,3)->dummy(1,3)) #cv,cv,h
	->reshape(3, 3*$Nstones);   #cv, cv*h
    my $MVv=((($V-$v) #cv h
	      ->mv(1,0)   # h cv
	      ->dummy(2,$Nstones) # h cv h
	     )*(
		 identity($Nstones)  # h h
		 ->dummy(1, 3)       # h cv h
	     ))->reshape(3, 3*$Nstones); # h cv*h

    my $matrix=$MR->glue(0, $MVt, $MVv); #c*h, c+c+h
    my ($lu, $perm, $par)=lu_decomp($matrix);
    my $det=det($matrix,{lu=>[$lu, $perm, $par]});
    my $delta=lu_backsub($lu, $perm, $par, $rhs);
    my $deltaR=$delta->slice([0,2]);
    my $deltaV=$delta->slice([3,5]);
    my $deltat=$delta->slice([6,8]);
    $R=$R+$deltaR;
    $V=$V+$deltaV;
    $t=$t+$deltat;
    last if(($deltaR->abs<$err)->all);
}
say $R->sum;
