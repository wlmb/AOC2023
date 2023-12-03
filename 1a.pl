#!/usr/bin/env perl
#!/usr/bin/env perl
use v5.36;
my $tot=0;
while(<>){
    /^.*?(\d)/ and my $f=$1 or die;
    /.*(\d).*?$/ and my $l=$1 or die;
    $tot += "$f$l";
}
say $tot;
