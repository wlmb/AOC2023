#!/usr/bin/env perl
use v5.36;
use List::Util qw(sum0);
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
my @parts;
my $total;
while(<>){ # read parts
    s/\s*{\s*// and s/\s*}\s*// or die "Wrong format";
    my %values;
    for(split /\s*,\s*/){
	/^\s*([xmas])\s*=\s*(\d+)\s*$/ or die "Wrong format";
	$values{$1}=$2;
    }
    $total+=rating(%values);
}
say $total;

sub rating(%values){
    my $wf="in";
  WF: while($wf!~/[AR]/){
      my @codes=$workflows{$wf}->@*;
      for(@codes){
	  my ($category, $test, $threshold, $next)=@$_;
	  $wf=$next, next WF if
	      $test eq ""
	      || $test eq ">" && $values{$category} > $threshold
	      || $test eq "<" && $values{$category} < $threshold
      }
      die "Shouldn't get here"; # no match nor default
  }
    return sum0 values %values if $wf eq "A";
}
