#!/usr/bin/env perl
use v5.36;
use List::Util qw(all min);
my $N=6;
my $total=0;
while(my $row_strings=diagram()){
    my $rows=to_matrix($row_strings);
    my $cols=ref_vert(ref_diag($rows));
    my %seen;
    my ($start, $end); # start and end of cycle
    my @pics;
    for(0..$N-1){
	my $pic=join "\n", map {join "", @$_} @$cols;
	($start, $end)=($seen{$pic}, $_), last if defined $seen{$pic};
	push @pics, $pic; # Notice push before cycling
	$seen{$pic}=$_;
	$cols=cycle($cols);
    }
    if(defined($start)){ # found cycle
	my $cycle_length=$end-$start;
	my $Nmod=($N-$start)%$cycle_length; # not $N-1 cause I pushed before cycling
	my $pic=$pics[$Nmod+$start];
	$cols=[map {chomp; [split ""]} split /^/, $pic];
    }
    my $load=load($cols);
    say $load;
}
sub cycle($arr){
    my $out=$arr;
    $out=rotate_right(tilt_left($out)) for (1..4);
    return $out;
}

sub load($arr){
    my $length=@$arr;
    my $load=0;
    for(@$arr){
	my @col=@$_;
	$load+=$col[$_]eq "O"?$length-$_:0 for(0..@col-1);
    }
    return $load;
}

sub tilt_left($arr){
    my @newarr;
    for(@$arr){
	my $col=join "", @$_;
	1 while $col=~s/(\.+)(O+)/$2$1/g;
	push @newarr, [split "", $col];
    }
    return \@newarr;
}

sub ref_diag($arr){ # reflection on main diagonal
    my @in=@$arr;
    my @cols;
    for my $i(0..@in-1){
	my @row=@{$in[$i]};
	$cols[$_][$i]=$row[$_] for(0..@row-1);
    }
    return \@cols;
}
sub ref_vert($arr){ # reflect vertically
    my @in=@$arr;
    my @out= reverse @in;
    return \@out;
}

sub rotate_right($arr){
    return ref_diag(ref_vert($arr));
}

sub diagram(){
    # read a complete diagram
    local $/=""; # paragraph at a time
    local $_=<>;
    return unless $_;
    my @row_strings=split /^/;
    pop @row_strings if $row_strings[-1]=~/^$/; # remove empty line
    chomp($_) for @row_strings;
    return \@row_strings if @row_strings;
    return;
}
sub to_matrix($rows){
    my @rows=map {[split ""]} @$rows;
    return \@rows;
}
sub transpose($arr){
    my @arr=@$arr;
    my $height=@arr;
    my $width=@{$arr[0]};
    my @out;
    for my $c(0..$width-1){
	push @out, [map {$arr[$_][$c]} 0..$height-1]
    }
    return \@out;
}
