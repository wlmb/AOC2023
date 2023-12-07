#!/usr/bin/env perl
use v5.38;
use experimental qw(class for_list);
use POSIX qw(floor);
class Range {
    field $start_source :param;
    field $start_destination :param;
    field $length :param;
    method start_source {$start_source};
    method start_destination {$start_destination};
    method length {$length};
    method end_source {$start_source+$length-1};
    method end_destination {$start_destination+$length-1};
    method in_range($s){$s>=$start_source && $s < $start_source+$length};
    method destination($s){
	return $s-$start_source+$start_destination if $self->in_range($s);
	return $s;
    }
}
class Map {
    use List::Util qw(first);
    field $source :param;
    field $destination :param;
    field %ranges;
    field $ordered=0;
    field @ordered;
    method source {$source};
    method destination {$destination};
    method ranges {values %ranges};
    method add_range($range) {$ordered=0; $ranges{$range->start_source}=$range};
    method sort_range {$ordered=1; @ordered=sort {$b <=> $a} keys %ranges};
    method range_before($s){
	$self->sort_range unless $ordered;
	my $r=first {$_<=$s} @ordered; # dumb search
	return unless defined $r;
	return $ranges{$r};
    }
    method range_after($s){
	$self->sort_range unless $ordered;
	my $r=first {$_>$s} reverse @ordered;
	return unless $r;
	return $ranges{$r};
    }
    method destination_of($s){
	my $range=$self->range_before($s);
	$self->sort_range unless $ordered;
	return $s unless defined $range;
	$range->destination($s);
    }
}
sub read_map(){
    return if eof;
    while(<>){last unless /^$/;} # skip blank
    return if eof;
    die "Wrong name" unless /^\s*(\w+)-to-(\w+)\s+map:/i;
    my ($source, $destination)=($1,$2);
    my $map=Map->new(source=>$source, destination=>$destination);
    while(<>){
	last if /^$/;
	my ($sd, $ss, $l)=split " ";
	my $range=Range->new(start_source=>$ss, start_destination=>$sd, length=> $l);
	$map->add_range($range);
    }
    return $map;
}
chomp(my $line=<>);
die "Expected seeds" unless $line=~s/^\s*seeds:\s*//i;
my @seeds=split " ", $line;
my %maps;
while(my $map=read_map()){
    $maps{$map->source}=$map;
}
my $best_location;
my $desired="location";
my @pending;
foreach my ($seed, $seed_nvals)(@seeds){
    push @pending, ["seed", $seed, $seed_nvals];
    while(@pending){
	my $source_range=shift @pending;
	my ($source, $initial, $nvals)=@$source_range;
	my $final=$initial+$nvals-1;
	if($source eq $desired){
	    $best_location //= $initial;
	    $best_location=$initial if $initial < $best_location;
	    next;
	}
	my $map=$maps{$source};
	my $destination=$map->destination;
	my $range0=$map->range_before($initial);
	my $range1=$map->range_after($initial);
	undef $range0 if defined $range0 and $range0->end_source < $initial;
	my $half=floor $nvals/2;
	if(not defined $range0){
	    push(@pending, [$destination, $initial, $nvals]), next if not defined $range1;
	    push(@pending, [$destination, $initial, $nvals]), next
		if $final < $range1->start_source;
	    push(@pending, [$source, $initial, $half]);
	    push(@pending, [$source, $initial+$half, $nvals-$half]);
	    next;
	}
	push(@pending, [$destination, $map->destination_of($initial), $nvals]), next
	    if $final <= $range0->end_source;
	push(@pending, [$source, $initial, $half]);
	push(@pending, [$source, $initial+$half, $nvals-$half]);
    }
}
say $best_location;
