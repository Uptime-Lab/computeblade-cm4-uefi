.PHONY: all
all: dist

.PHONY: init
init:
	git submodule update --init --depth 1 --recursive


.PHONY: build
build: init
	docker buildx build --progress=plain . -o out --no-cache

.PHONY: dist
dist: init build
	mkdir -p dist
	cp out/* dist/
	cp rpi-firmware/boot/fixup4.dat dist/
	cp rpi-firmware/boot/start4.elf dist/
	cp rpi-firmware/boot/bcm2711-rpi-4-b.dtb dist/
	cp rpi-firmware/boot/bcm2711-rpi-cm4.dtb dist/
	cp rpi-firmware/boot/bcm2711-rpi-400.dtb dist/
	cp -rf rpi-firmware/boot/overlays dist/
	mkdir -p dist/firmware
	cp -rf firmware/* dist/firmware/
	cp config.txt dist/
	zip -r dist.zip dist

