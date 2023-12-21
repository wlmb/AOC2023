#!/usr/bin/env perl
use v5.36;
use List::Util qw(all);
use Math::Prime::Util qw(lcm);
my %modules; #name=>[kind=>..., state=>..., dests=>[...], from=>[...]
my %processors=(""=>\&broadcast, "%"=>\&flipflop, "&"=>\&conjunction, "END"=>\&end);
my %negate_pulse=qw(low high high low);
my %flip_state=qw(off on on off);

while(<>){ # Read
    die "Wrong format" unless /^\s*(\W)?(\w+)\s*->\s*(.*?)\s*$/;
    my ($kind, $name, $dests)=($1//"", $2, $3);
    my @dests=split /\s*,\s*/, $dests;
    create($name, $kind, [@dests], $processors{$kind});
}

for(keys %modules){ # initialize
    my $module=$modules{$_};
    $module->{state}="off" if $module->{kind} eq "%";
    do {$module->{state}{$_}="low" for $module->{from}->@*}
       if $module->{kind} eq "&";
}
my $count=0;
my $lasatlast="rx";
my $last=$modules{rx}->{from}[0];               # qn
my @penultimate=$modules{$last}{from}->@*; 	#/qz|cq|jx|tt/

my %periods;
my @queue;
my @nextqueue;
COUNT: while(1){
    push @queue, ["button", "low", "broadcaster"];
    ++$count;
    while(@queue){
	my $next=shift @queue;
	do {$periods{$_}=$count if $next->[0] eq $_ && $next->[2] eq "qn"
	    && $next->[1] eq "high" && !defined $periods{$_}} for @penultimate;
	last COUNT if all {defined $periods{$_}} @penultimate;
	dispatch($next);
    }
}
say "$_ $periods{$_}" for @penultimate;
say "Result: ", lcm(map {$periods{$_}} @penultimate);

sub create($name, $kind, $dests, $processor){
    $modules{$name}//={};
    $modules{$name}={$modules{$name}->%*,
			 kind=>$kind,dests=>$dests, processor=>$processor};
    # push $modules{$_}{from}->@*, $name for @$dests;
    my $end_processor=$processors{"END"};
    for(@$dests){
	$modules{$_}//={kind=>"END", processor=>$end_processor};
	push $modules{$_}{from}->@*, $name;
    }
}
sub dispatch($instruction){
    my ($from, $pulse, $target)=@$instruction;
    my $processor=$modules{$target}{processor};
    $processor->($from, $pulse, $target)
}
sub broadcast($from, $pulse, $self){
    push @queue, [$self, $pulse, $_] for $modules{$self}{dests}->@*;
}
sub flipflop($from, $pulse, $self){
    my $flipflop=$modules{$self};
    return if $pulse eq "high";
    $flipflop->{state}=$flip_state{my $old_state=$flipflop->{state}};
    my $nextpulse=$old_state eq "off"?"high":"low";
    push @queue, [$self, $nextpulse, $_] for $flipflop->{dests}->@*;
}
sub conjunction($from, $pulse, $self){
    my $conjunction=$modules{$self};
    my $state=$conjunction->{state};
    $state->{$from}=$pulse;
    my $nextpulse=(all {$_ eq "high"} values $state->%*)?"low":"high";
    push @queue, [$self, $nextpulse, $_] for $conjunction->{dests}->@*;
}
sub end($from, $pulse, $self){
}
