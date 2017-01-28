#/bin/sh

file=$1
shift
urls=$@

mode="searchLocationBegin"

while read -r line
do
	case $mode in
		"searchLocationBegin")
			echo $line
			for url in $urls
			do
				if [ "$(echo $line | grep "<Location.*$url.*>" )" ]
				then
					echo 'SetHandler weblogic-handler'
					echo 'ErrorPage https://externet.ac-creteil.fr/maintenance/'
					mode="searchLocationEnd"
				fi
			done
			;;
		"searchLocationEnd")
			if [ "$(echo $line | grep '</Location>')" ]
			then
				echo $line
				mode="searchLocationBegin"
			fi
			;;
	esac 
done < $file
