# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the LICENSE_BSD0 file.

TOIT_EXE := toit
VERSION := $(shell $(TOIT_EXE) version)
ENVELOPE_URL := https://github.com/toitlang/envelopes/releases/download/$(VERSION)/firmware-esp32.envelope.gz
WIFI_CREDENTIALS := {"wifi.ssid":"<my-ssid>","wifi.password":"<my-password>"}

.PHONY: all
all: build/ota.bin

# Always repuild the firmware envelope since we modify it.
.PHONY: build/firmware.envelope
build/firmware.envelope: build/firmware.envelope.gz
	gunzip -c $< > $@

build/firmware.envelope.gz: build
	mkdir -p build
	curl -L -o $@ $(ENVELOPE_URL)

build/%.snapshot: %.toit
	mkdir -p build
	$(TOIT_EXE) compile --snapshot -O2 -o $@ $<

build/ota.bin: build/validate.snapshot build/firmware.envelope
	$(TOIT_EXE) tool firmware -e build/firmware.envelope container install validate build/validate.snapshot
	$(TOIT_EXE) tool firmware -e build/firmware.envelope property set wifi '$(WIFI_CREDENTIALS)'
	$(TOIT_EXE) tool firmware -e build/firmware.envelope extract --format=binary -o $@

build/ota-encrypted.bin: build/ota.bin
	$(TOIT_EXE) run encrypt.toit $< $@

.PHONY: serve
serve: build/ota-encrypted.bin
	cd build && python3 -m http.server 8000

.PHONY: version
version:
	@echo $(VERSION)

.PHONY: clean
clean:
	rm -rf build
