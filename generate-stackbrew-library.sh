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
	for variant in '' alpine; do
		[ -f "$path${variant:+/$variant}/Dockerfile" ] || continue

		echo

		commit="$(git log -1 --format='format:%H' -- "$path${variant:+/$variant}")"

		suffix="${path#*-}" # "jre7"

		version="$(grep -m1 'ENV JETTY_VERSION ' "$path${variant:+/$variant}/Dockerfile" | cut -d' ' -f3)"

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
		# e.g. 9.2.10, 9.2, 9, 9.3-alpine
		if [ "$suffix" = "$defaultSuffix" ]; then
			for va in "${versionAliases[@]}"; do
				outputTag "$va${variant:+-$variant}" "$url" "$commit" "$path${variant:+/$variant}"
			done
		fi

		# Output ${versionAliases[@]} with suffixes
		# e.g. 9.2.10-jre7, 9.2-jre7, 9-jre7, 9-jre8-alpine
		for va in "${versionAliases[@]}"; do
			outputTag "$va-$suffix${variant:+-$variant}" "$url" "$commit" "$path${variant:+/$variant}"
		done

		# Output custom aliases
		# e.g. latest, jre7, jre8, latest-alpine
		if [ ${#aliases[$path]} -gt 0 ]; then
			for va in ${aliases[$path]}; do
				if [ ! -z "$variant" -a "$va" = 'latest' ]; then
					va="$variant"
				else
					va="$va${variant:+-$variant}"
				fi
				outputTag "$va" "$url" "$commit" "$path${variant:+/$variant}"
			done
		fi
	done
done
