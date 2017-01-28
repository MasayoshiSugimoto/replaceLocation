#!/usr/bin/perl

use strict;
use warnings;

use Path::Class;
use File::Basename;
use Cwd;
use autodie; # die if problem reading or writing a file

################################################################################
# User inputs
################################################################################

my $inputFile=$ARGV[0];
shift;
my @urls=@ARGV;

################################################################################
# Functions
################################################################################

my $handler=\&beforeHandler;

sub println {
	my ($message) = @_;
	print("$message\n");
}

sub beforeHandler {
	my ($line) = @_;
	print($line);
	
	foreach my $url (@urls) {
		if ($line =~ /<Location.*${url}.*>/) {
			println("SetHandler weblogic-handler");
			println("ErrorPage https://externet.ac-creteil.fr/maintenance/");
			$handler = \&insideHandler;
		}
	}
}

sub insideHandler {
	my ($line) = @_;
	if ($line =~ /<\/Location>/) {
		print($line);
		$handler = \&beforeHandler;
	}
}

################################################################################
# Script
################################################################################

my $file = Path::Class::File->new($inputFile);
my $fileHandle = $file->openr();

while(my $line = $fileHandle->getline()) {
	&$handler($line);
}
