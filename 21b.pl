#!/usr/bin/env perl
use v5.36;
use PDL;
use PDL::NiceSlice;
die unless @ARGV==2;
my $M=shift;
#my $M=26501365;
my @dirs=map {pdl $_} ([0,1],[1,0],[-1,0],[0,-1]);
my $start;
my $map;
my @map;
my %type;
my $y=0;
my $xmax;
while(<>){
    chomp;
    last if /^$/;
    my @line=split "";
    s/S/0/ || s/#/-1/ || s /./-2/ for @line;
    push @map, [@line];
}
$map=pdl(@map);
my ($width,$height)=map {$map->dim($_)} (0,1);
my ($cx, $cy)=map {($_-1)/2} ($width,$height);
# check assumptions
die "Wrong assumptions" unless
    $map($cx, $cy) == 0
    && ($map($cx,  0:$cy-1)==-2)->all
    && ($map($cx, $cy+1:-1)==-2)->all
    && ($map(0:$cx-1,  $cy)==-2)->all
    && ($map($cx+1:-1, $cy)==-2)->all;
# Put start at 0,0 NW, y grows downward
my $count=compute_SE($map); # southeast
$count+=compute_SE($map(-1:0)); # and reflections for other quadrants
$count+=compute_SE($map(:,-1:0));
$count+=compute_SE($map(-1:0,-1:0));
$count -=2*$M+3 if $M%2==0; # don't double count axes and origin
$count -=2*($M+1) if $M%2==1;
say $count;

sub compute_SE($map){
    my ($SE, $SW, $NE, $NW)= map {$_->copy}
	( # Note shuffling. NW contains starting point. Note overlapping highways
	  $map(0:$cx,0:$cy),  $map($cx:2*$cx,0:$cy),
	  $map(0:$cx,$cy:2*$cy),$map($cx:2*$cx,$cy:2*$cy));
    my $count=compute_aux($NW, $NE, $SW, $SE);
    return $count;
}

sub compute_aux($NW, $NE, $SW, $SE){ #
    $_.=-2 for ($NE((-1),:), $SW(:,(-1)), $SE((-1),:), $SE(:,(-1))); # add highway plots
    prepare($_) for ($NW, $NE, $SW, $SE);
    # remove added highways:
    $NE=$NE(0:-2,    );
    $SW=$SW( :  ,0:-2);
    $SE=$SE(0:-2,0:-2);
    my ($wx, $wy)=$NW->dims;
    my @regions=(
	{name=>"NW", map=>$NW,  offset=>pdl(0,0),     diameter=>$NW->max,
	 plots=>which($NW>=0)->nelem},
	{name=>"NE", map=>$NE,  offset=>pdl($wx,0),   diameter=>$NE->max,
	 plots=>which($NE>=0)->nelem},
	{name=>"SW", map=>$SW,  offset=>pdl(0,$wy),   diameter=>$SW->max,
	 plots=>which($SW>=0)->nelem},
	{name=>"SE", map=>$SE,  offset=>pdl($wx,$wy), diameter=>$SE->max,
	 plots=>which($SE>=0)->nelem}
	);
    for(@regions){
	my $map=$_->{map};
	my %count;
	++$count{$_} for grep {$_>=0} $map->list;
	# accumulate even and odd counts
	$count{$_}+=$count{$_-2} for 2..$_->{diameter};
	$_->{count}={%count};
    }
    my $superdiameter=pdl(map{$_->{offset}->sumover+$_->{diameter}} @regions)->max;
    my $superplots=pdl(map{$_->{plots}} @regions)->sum;
    my $count=0;
    my @border;
    my $bxmax=my $bx=floor($M/$width);
    my $need=$M-$bx*$width;
    while($bx>=0 && 0<=$need<=$superdiameter){
	my $block=0;
	$block+=compute_one($need, $_) for(@regions);
	push @border, $block;
	--$bx;
	$need+=$width;
    }
    # Now bx is the farthest block that has to be counted completely
    my ($withcorner, $withoutcorner);
    ($withcorner, $withoutcorner)=(($bx+2)**2/4, $bx*($bx+2)/4) if $bx%2==0;
    ($withcorner, $withoutcorner)=(($bx+1)**2/4, ($bx+1)*($bx+3)/4)  if $bx%2==1;
    my ($even, $odd)=$M%2==0?($withcorner, $withoutcorner):($withoutcorner, $withcorner);
    my ($plotseven, $plotsodd)=$superplots%2==0
	?($superplots/2,     $superplots/2)
	:(($superplots+1)/2, ($superplots-1)/2);
    $count = $plotseven*$even+$plotsodd*$odd;
    #there are $bx+1 columns of @border partial blocks blocks
    my $boundary=($bx+1)*pdl(@border)->sum;
    # there are 1..@border blocks at the corner
    while(@border){
	$boundary+=pdl(@border)->sum;
	pop @border;
    }
    $count+=$boundary;
    return $count;
}

sub compute_one($steps, $region){
    my $pending_steps = $steps-$region->{offset}->sumover; # move to start
    #my $map=$region->{map};
    #my $result=which(($map>=0) & ($map <= $pending_steps) & (($pending_steps-$map)%2==0))->nelem;
    my $diameter=$region->{diameter};
    my $result;
    if($pending_steps>$diameter){
	$result=$region->{count}{$diameter} if ($pending_steps-$diameter)%2==0;
	$result=$region->{count}{$diameter-1} if ($pending_steps-$diameter)%2==1;
    }else{
	$result=$region->{count}{$pending_steps};
    }
    $result//=0;
    return $result;
}

sub prepare($map){
    # set distances from upper left corner 0 based
    my $last=pdl $map->dims;
    my $neighbors=pdl[[1,0],[0,1],[-1,0],[0,-1]];
    my @pending;
    push @pending, [0,pdl(0,0)];
    $map(0,0).=0;

    while(@pending){
	my ($d, $r)=(shift @pending)->@*;
	++$d;
	for(($r+$neighbors)->dog){
	    next if(($_<0) | ($_>=$last))->orover;
	    my ($x, $y)=$_->dog;
	    my $site=$map($x,$y);
	    next if $site==-1; #skip rocks
	    next if $site != -2 && $site <= $d; #already visited
	    $site.=$d; #update neighbors
	    push @pending, [$d, $_]; #schedule neighbors
	}
    }
}
