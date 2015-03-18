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

paths=( */ )
paths=( "${paths[@]%/}" )
url='git://github.com/md5/docker-jetty'

echo '# maintainer: Mike Dillon <mike@embody.org> (@md5)'
echo

for path in "${paths[@]}"; do
	commit="$(git log -1 --format='format:%H' -- "$path")"

	suffix="${path#*-}" # "jre7"

	version="$(grep -m1 'ENV JETTY_VERSION ' "$path/Dockerfile" | cut -d' ' -f3)"

	if [[ "$version" == *.v* ]]; then
		# Release version
		versionAliases=()
		while [[ "$version" == *.* ]]; do
			version="${version%.*}"
			versionAliases+=("$version")
		done
	else
		# Non-release version
		versionAliases=("$version")
	fi

	# Output ${versionAliases[@]} without suffixes
	# e.g. 9.2.10, 9.2, 9
	if [ "$suffix" = "$defaultSuffix" ]; then
		for va in "${versionAliases[@]}"; do
			echo "$va: ${url}@${commit} $path"
		done
	fi

	# Output ${versionAliases[@]} with suffixes
	# e.g. 9.2.10-jre7, 9.2-jre7, 9-jre7
	for va in "${versionAliases[@]}"; do
		echo "$va-$suffix: ${url}@${commit} $path"
	done

	# Output custom alises
	# e.g. latest, jre7, jre8
	if [ ${#aliases[$path]} -gt 0 ]; then
		for va in ${aliases[$path]}; do
			echo "$va: ${url}@${commit} $path"
		done
	fi

	echo
done
