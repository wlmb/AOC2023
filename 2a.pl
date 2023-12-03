#!/usr/bin/env perl
#!/usr/bin/env perl
# Sum possible game ids for 12 red cubes, 13 green cubes, and 14 blue cubes
use v5.36;
my %available=(red=>12, green=>13, blue=>14);
my $total=0;
while(<>){
    s/Game\s*(\d+):\s*// or die;
    my $id=$1;
    my $impossible=0;
    SUBSET: for(split /\s*;\s*/){
	for(split /\s*,\s*/){
	    /^(\d+)\s*(.*)$/  or die;
	    my ($quantity, $color)=($1, $2);
	    $impossible=1,last SUBSET if $quantity>$available{$color};
	}
    }
    $total += $id unless $impossible;
}
say $total;
