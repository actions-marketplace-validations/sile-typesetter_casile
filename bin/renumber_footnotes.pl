#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';

my $offset = 0;
my $last = 0;

sub calculate_offset {
	my ($i) = @_;
	if ($i == 1) {
		$offset += $last;
	}
	$last = $i;
}

sub add_offset {
	my ($i) = @_;
	my $j = $i + $offset;
	return "[^$j]";
}

for my $line (<>) {
	if (my @matches = $line =~ /(?<!^)\[\^(\d+)\]/g) {
		for my $count (@matches) {
			calculate_offset($count);
		}
	}
	$line =~ s/\[\^(\d+)\]/add_offset($1)/ge;
	print $line;
}
