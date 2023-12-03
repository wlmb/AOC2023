#!/usr/bin/env perl
#!/usr/bin/env perl
# Sum minimum powers of games
use v5.36;
use List::Util qw(product);
my $total=0;
while(<>){
    s/Game\s*\d+:\s*// or die;
    my %minima=(red=>0, green=>0, blue=>0);
    for(split /\s*;\s*/){
	for(split /\s*,\s*/){
	    /^(\d+)\s*(.*)$/  or die;
	    my ($quantity, $color)=($1, $2);
	    ($_<$quantity) && ($_=$quantity) for $minima{$color};
	}
    }
    my $product=product values %minima;
    $total += $product;
}
say $total;
