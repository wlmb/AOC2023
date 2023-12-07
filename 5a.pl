#!/usr/bin/env perl
use v5.38;
use experimental 'class';
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
    method map($s){
	$self->sort_range unless $ordered;
	my $r=first {$_<=$s} @ordered; # dumb search
	return $s unless defined $r;
	my $range=$ranges{$r};
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
my $location;
my $desired="location";
foreach my $seed(@seeds){
    my $from="seed";
    my $number=$seed;
    while(1){
	my $map=$maps{$from};
	my $to=$map->destination;
	$number=$map->map($number);
	last if $to eq "location";
	$from=$to;
    }
    $location//=$number;
    $location=$number if $number<$location;
}
say $location;
