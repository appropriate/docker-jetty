#!/bin/bash

set -ueo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

MAVEN_METADATA_URL='https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/maven-metadata.xml'

available=( $( curl -sSL "$MAVEN_METADATA_URL" | grep -Eo '<(version)>[^<]*</\1>' | awk -F'[<>]' '{ print $3 }' | sort -Vr ) )

for version in "${versions[@]}"; do
	plainVersion="${version%%-*}" # "9.2"
	suffix="${version#*-}" # "jre7"

	baseImage='java'
	case "$suffix" in
		jre*|jdk*)
			baseImage+=":${suffix:3}-${suffix:0:3}" # ":7-jre"
			;;
	esac

	fullVersion=
	for candidate in "${available[@]}"; do
		# Pick the first $candidate to match $majorVersion.*
		if [[ "$candidate" == "$plainVersion".* ]]; then
			fullVersion="$candidate"
			break
		fi
	done

	if [ -z "$fullVersion" ]; then
		echo >&2 "Unable to find Jetty package for $version"
		exit 1
	fi

	(
		set -x
		sed -ri '
			s/^(FROM) .*/\1 '"$baseImage"'/;
			s/^(ENV JETTY_VERSION) .*/\1 '"$fullVersion"'/;
		' "$version/Dockerfile"
	)
done
