#!/usr/bin/env perl
use v5.36;
use List::Util qw(all min);
my $total=0;
while(my $row_strings=diagram()){
    my $rows=to_matrix($row_strings);
    my $cols=ref_diag($rows);
    my $newcols=tilt_left($cols);
    my $load=load($newcols);
    say $load;
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
