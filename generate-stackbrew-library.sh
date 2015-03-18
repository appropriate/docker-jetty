#!/bin/bash
set -ueo pipefail

declare -A aliases
aliases=(
	[9.2-jre7]='latest jre7'
	[9.2-jre8]='jre8'
)
defaultJava='7'
defaultSuffix="jre${defaultJava}"

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/md5/docker-jetty'

echo '# maintainer: Mike Dillon <mike@embody.org> (@md5)'

for version in "${versions[@]}"; do
	commit="$(git log -1 --format='format:%H' -- "$version")"

	suffix="${version#*-}" # "jre7"

	fullVersion="$(grep -m1 'ENV JETTY_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	fullVersion="${fullVersion%.v*}"
	majorMinorVersion="${fullVersion%.*}"
	majorVersion="${fullVersion%%.*}"

	isMilestone=
	if [[ "$fullVersion" == *.M* ]]; then
		isMilestone=1
	fi

	versionAliases=()

	if [ "$suffix" = "$defaultSuffix" ]; then
		versionAliases+=( $fullVersion ) # 9.2.10

		if ! [ "$isMilestone" ]; then
			versionAliases+=( $majorMinorVersion $majorVersion ) # 9.2 9
		fi
	fi

	versionAliases+=( $fullVersion-$suffix ) # 9.2.10-jre7
	if ! [ "$isMilestone" ]; then
		versionAliases+=( $majorMinorVersion-$suffix $majorVersion-$suffix ) # 9.2-jre7 9-jre7
	fi

	if [ ${#aliases[$version]} -gt 0 ]; then
		versionAliases+=( ${aliases[$version]} )
	fi

	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
done
