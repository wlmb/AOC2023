#!/usr/bin/env perl
use v5.36;
use List::Util qw(min max sum0 product);
my %workflows;
while(<>){ # read workflows
    chomp;
    last if /^\s*$/;
    /^\s*(\w+)\s*\{(.*)\}/ or die "wrong format";
    my ($name,$instructions)=($1,$2);
    my @instructions=split /\s*,\s*/, $instructions;
    my @codes; # [category, test, threshold, next]
    for(@instructions){
	push @codes, ["", "", "", $1] if /^\s*(\w+)\s*$/;
	push @codes, [$1, $2, $3, $4] if /\s*(\w+)\s*([><])\s*(\d+)\s*:\s*(\w+)\s*$/;
    }
    $workflows{$name}=[@codes];
}
die "Missing in" unless defined $workflows{in};
my %backflows;
for my $wf(keys %workflows){
    my @codes=$workflows{$wf}->@*;
    my @intervals;
    push @intervals, {x=>[1,4000], m=>[1,4000], a=>[1,4000], s=>[1,4000]};
    for my $code (@codes){
	my($category, $test, $threshold, $next)=@$code;
	my @next_intervals;
	for(@intervals){
	    push($backflows{$next}->@*, [$wf, {%$_}]), next if $category eq "";
	    my ($newlow, $newhigh)= my ($low, $high)=my @interval=$_->{$category}->@*;
	    $newlow=$threshold+1 if $test eq ">";
	    $newhigh=$threshold-1 if $test eq "<";
	    push $backflows{$next}->@*, [$wf, {%$_, $category=>[$newlow, $newhigh]}]
	       if $newlow<=$newhigh;
	    push @next_intervals, {%$_, $category=>[$low, $newlow-1]} if $low<$newlow;
	    push @next_intervals, {%$_, $category=>[$newhigh+1, $high]} if $newhigh<$high;
	}
	@intervals=@next_intervals;
    }
}
my @results=merge("A");
my $total=0;
for(@results){
    my $product = product map {1+$_->[1]-$_->[0]} values %$_;
    $total += $product;
}
say $total;

sub merge($wf){
    state $all={x=>[1,4000], m=>[1,4000], a=>[1,4000], s=>[1,4000]};
    return ($all) if($wf eq "in");
    my @bf=$backflows{$wf}->@*; #from {codes}
    my @result;
    for(@bf){
	my @previous_codes=merge($_->[0]);
	my $current_code=$_->[1];
	push @result, grep {$_} map {code_intersect($current_code, $_)} @previous_codes;
    }
    return @result;
}

sub code_intersect($c1, $c2){
    my %result;
    for(keys %$c1){
	my $intersection=intersection($c1->{$_}, $c2->{$_});
	return unless $intersection;
	$result{$_}=$intersection;
    }
    return {%result};
}


sub intersection(@intervals){
    return unless @intervals;
    return @intervals if @intervals==1;
    my $low=max map {$_->[0]} @intervals;
    my $high=min map {$_->[1]} @intervals;
    return [$low,$high] if $low<=$high;
    return;
}
sub union(@intervals){
    return unless @intervals;
    return @intervals if @intervals==1;
    my @sorted=sort {$a->[0]<=>$b->[0] || $a->[1]<=>$b->[1]} @intervals;
    my @results;
    my @result;
    while(@sorted){
	my @current=shift @sorted;
	@result=@current unless @result;
	push(@results, [@result]), @result=(), next if $result[1]<$current[0];
	$result[1]=$current[1];
    }
    push @results, [@result] if @result;
    return @results;
}
