#!/usr/bin/env perl
#!/usr/bin/env perl
use v5.36;
my $tot=0;
my @digits=qw(one two three four five six seven eight nine);
my $i=1;
my %digit;
$digit{$_}=$i++ for @digits;
$digit{$_}=$_ for 0..9;
my $digit=join "|", @digits, '\d';
my $first=qr"^.*?($digit)"i;
my $last=qr".*($digit).*?$"i;
while(<>){
    /$first/ and my $f=$1 or die;
    /$last/ and my $l=$1 or die;
    $tot += "$digit{$f}$digit{$l}";
}
say $tot;
