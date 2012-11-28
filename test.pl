#!/usr/bin/perl
use strict;
use warnings;

open(my $writefile, ">", "nums.txt");
for(my $counter = 0; $counter <=50; $counter++) {
    print $writefile rand(200) . "\n";
}
close($writefile);
