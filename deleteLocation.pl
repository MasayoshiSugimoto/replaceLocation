#!/usr/bin/perl

# filtre qui supprime les balises Location pass▒es
# en argument du fichier de configuration d'apache

open(HANDLE, $ARGV[0] ) || die "usage : location.pl fichier.conf url1 url2 etc.." ;
$tot=@ARGV;
$lurl="";
$ligne="";

sub supprimer
{
	while ($ligne=<HANDLE>)
	{
		chop ($ligne);
		return if ( $ligne =~ /<\/Location>/ );
	}
}

sub verifier
{
	my $i=0;

	for ( $i=1; $i < $tot; $i++ )
	{
		if ( $lurl eq $ARGV[$i] )
		{
			printf("<Location /%s>\n",$lurl);
			printf("SetHandler weblogic-handler\n");
			printf("ErrorPage https://externet.ac-creteil.fr/maintenance/\n");
			supprimer();
			printf("</Location>\n");
			return;
		}
	}
	printf("%s\n",$ligne);
}

while ($ligne=<HANDLE>)
{
	chop ($ligne);
	if ( $ligne =~ /<Location\s+\/([-_A-Za-z0-9]+)>/ )
	{
		$lurl=$1;
		verifier();
	}
	else
	{
		printf("%s\n",$ligne);
	}
}

close (HANDLE);
