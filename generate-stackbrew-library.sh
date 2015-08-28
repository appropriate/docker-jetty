#!/bin/bash
set -ueo pipefail

declare -A aliases
aliases=(
	[9.2-jre7]='jre7'
	[9.3-jre8]='latest jre8'
)
defaultJava='8'
defaultSuffix="jre${defaultJava}"

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

paths=( */Dockerfile )
paths=( $( printf '%s\n' "${paths[@]%/Dockerfile}" | sort -Vr ) )
url='git://github.com/appropriate/docker-jetty'

echo '# maintainer: Mike Dillon <mike@appropriate.io> (@md5)'
echo '# maintainer: Greg Wilkins <gregw@webtide.com> (@gregw)'

declare -A tagsSeen
tagsSeen=()
outputTag() {
	local tag="$1"
	local url="$2"
	local commit="$3"
	local path="$4"

	if [ ${#tagsSeen[$tag]} -gt 0 ]; then
		return
	fi

	echo "$tag: ${url}@${commit} $path"
	tagsSeen[$tag]=1
}

for path in "${paths[@]}"; do
	echo

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
			outputTag "$va" "$url" "$commit" "$path"
		done
	fi

	# Output ${versionAliases[@]} with suffixes
	# e.g. 9.2.10-jre7, 9.2-jre7, 9-jre7
	for va in "${versionAliases[@]}"; do
		outputTag "$va-$suffix" "$url" "$commit" "$path"
	done

	# Output custom aliases
	# e.g. latest, jre7, jre8
	if [ ${#aliases[$path]} -gt 0 ]; then
		for va in ${aliases[$path]}; do
			outputTag "$va" "$url" "$commit" "$path"
		done
	fi
done
