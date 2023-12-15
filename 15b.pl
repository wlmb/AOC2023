#!/usr/bin/env perl
use v5.36;
use List::MoreUtils qw(firstidx);
my @boxes;
while(<>){
    chomp;
    for(split ","){
	/(.*)([=-])(.*)/;
	my ($label,$operation,$focal) =($1,$2,$3);
	my $nbox=hash($label);
	my $box=$boxes[$nbox];
	if($operation eq "-"){
	    my $pos = firstidx {$_->{label} eq $label} $box->@*;
	    splice $box->@*, $pos, 1 if $pos>=0;
	}else{ # $operation eq "=")
	    my $lens={label=>$label, focal=>$focal};
	    my $pos = firstidx {$_->{label} eq $label} $box->@*;
	    push $box->@*, $lens if $pos==-1;
	    splice $box->@*, $pos, 1, $lens if $pos >= 0;
	}
	$boxes[$nbox]=$box;
    }
}
my $total=0;
my $nbox=0;
for(@boxes){
    ++$nbox;
    next unless $_;
    my $power=0;
    my $slot=0;
    for($_->@*){
	++$slot;
	$power+=$nbox*$slot*$_->{focal};
    }
    $total+=$power;
}
say $total;

sub hash($label){
    my $hash=0;
    $hash = ($hash+ord)*17%256 for(split "", $label);
    return $hash;
}
