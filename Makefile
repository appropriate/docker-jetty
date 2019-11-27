VERSIONS = $(foreach df,$(wildcard */Dockerfile),$(df:%/Dockerfile=%))

all: build

build: $(VERSIONS)

define jetty-version
$1:
	docker build -t jetty:$(shell echo $1 | sed -e 's/\//-/g') $1
endef
$(foreach version,$(VERSIONS),$(eval $(call jetty-version,$(version))))

9.4-jdk13-slim: 9.4-jdk13
9.4-jre11: 9.4-jdk13
9.4-jre11-slim: 9.4-jdk13
9.4-jre8: 9.4-jdk13

update:
	docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./update.sh

library:
	@docker run --rm -v $$(pwd):/work -w /work buildpack-deps ./generate-stackbrew-library.sh

.PHONY: all build update library $(VERSIONS)
