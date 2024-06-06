.PHONY: all
all: build

.PHONY: init
init:
	git submodule update --init --depth 1 --recursive


.PHONY: build
build: init
	docker buildx build --progress=plain . -o out --no-cache
