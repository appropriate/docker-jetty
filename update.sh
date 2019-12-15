#!/bin/bash

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

paths=( "$@" )
if [ ${#paths[@]} -eq 0 ]; then
	paths=( */ )
fi
paths=( "${paths[@]%/}" )

MAVEN_METADATA_URL='https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/maven-metadata.xml'

available=( $( curl -sSL "$MAVEN_METADATA_URL" | grep -Eo '<(version)>[^<]*</\1>' | awk -F'[<>]' '{ print $3 }' | sort -Vr ) )

for path in "${paths[@]}"; do
	version="${path%%-*}" # "9.2"
	jvm="${path#*-}" # "jre11-slim"
	disto=$(expr "$jvm" : '\(j..\)[0-9].*') # jre
	variant=$(expr "$jvm" : '.*-\(.*\)') # slim
	release=$(expr "$jvm" : 'j..\([0-9][0-9]*\).*') # 11
	label=${release}-${disto}${variant:+-$variant} # 11-jre-slim

	milestones=()
	releaseCandidates=()
	fullReleases=()
	for candidate in "${available[@]}"; do
		if [[ "$candidate" == "$version".* ]]; then
			if [[ "$candidate" == *.M* ]]; then
				milestones+=("$candidate")
			elif [[ "$candidate" == *.RC* ]]; then
				releaseCandidates+=("$candidate")
			elif [[ "$candidate" == *.v* ]]; then
				fullReleases+=("$candidate")
			fi
		fi
	done

	fullVersion=
	if [ -n "${fullReleases-}" ]; then
		fullVersion="$fullReleases"
	elif [ -n "${releaseCandidates-}" ]; then
		fullVersion="$releaseCandidates"
	elif [ -n "${milestones-}" ]; then
		fullVersion="$milestones"
	fi

	if [ -z "$fullVersion" ]; then
		echo >&2 "Unable to find Jetty package for $path"
		exit 1
	fi

	if [ -d "$path" ]; then
	    cp docker-entrypoint.sh generate-jetty-start.sh "$path"
	    if [ "$version" == "9.4" ] ; then
	        echo '# DO NOT EDIT. Edit Dockerfile-9.4 and use update.sh' > "$path"/Dockerfile
	    	cat Dockerfile-9.4 >> "$path"/Dockerfile
	        sed -ri 's/^(FROM openjdk:)LABEL/\1'"$label"'/; ' "$path/Dockerfile"
	    fi
	    sed -ri 's/^(ENV JETTY_VERSION) .*/\1 '"$fullVersion"'/; ' "$path/Dockerfile"
	fi
done
