#!/bin/bash
set -ueo pipefail
shopt -s globstar

declare -A aliases
aliases=(
	[9.4-jdk13]='latest jdk13'
)
defaultJdk="jdk13"

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

paths=( **/Dockerfile )
paths=( $( printf '%s\n' "${paths[@]%/Dockerfile}" | sort -k 1.1,1.3Vr -k 1,8 ) )
url='https://github.com/appropriate/docker-jetty.git'

cat <<-EOH
	Maintainers: Mike Dillon <mike@appropriate.io> (@md5),
	             Greg Wilkins <gregw@webtide.com> (@gregw)
	GitRepo: $url
EOH

declare -a tags
declare -A tagsSeen=()
addTag() {
	local tag="$1"

	if [ ${#tagsSeen[$tag]} -gt 0 ]; then
		return
	fi

	tags+=("$tag")
	tagsSeen[$tag]=1
}

for path in "${paths[@]}"; do
	tags=()

	commit="$(git log -1 --format='format:%H' -- "$path")"

	major="${path%%-*}" # "9.2"
        if [[ "$major" == "9.4" ]]; then
		version="$(grep -m1 'ENV JETTY_VERSION ' "9.4-jdk13/Dockerfile" | cut -d' ' -f3)"
	else
		version="$(grep -m1 'ENV JETTY_VERSION ' "$path/Dockerfile" | cut -d' ' -f3)"
	fi

	# Determine the JDK
	jdk=${path#*-} # "jre7"

	# Collect the potential version aliases
	declare -a versionAliases
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

	# Output ${versionAliases[@]} without JDK
	# e.g. 9.2.10, 9.2, 9 
	if [ "$jdk" = "$defaultJdk" ]; then
		for va in "${versionAliases[@]}"; do
			addTag "$va"
		done
	fi

	# Output ${versionAliases[@]} with JDK suffixes
	# e.g. 9.2.10-jre7, 9.2-jre7, 9-jre7, 9-jre11-slim
	for va in "${versionAliases[@]}"; do
		addTag "$va-$jdk"
	done

	# Output custom aliases
	# e.g. latest, jre7, jre8
	if [ ${#aliases[$path]} -gt 0 ]; then
		for va in ${aliases[$path]}; do
			addTag "$va"
		done
	fi

	cat <<-EOE

		Tags:$(IFS=, ; echo "${tags[*]/#/ }")
		Architectures: $(< "$path/arches")
		Directory: $path
		GitCommit: $commit
	EOE
done
