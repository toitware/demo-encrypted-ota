# Copyright (C) 2023 Toitware ApS.
# Use of this source code is governed by a Zero-Clause BSD license that can
# be found in the LICENSE_BSD0 file.

TOIT_SDK := /opt/toit-sdk
TOIT_EXE := /opt/toit-sdk/bin/toit
VERSION := $(shell $(TOIT_SDK)/bin/toit version)
ENVELOPE_URL := https://github.com/toitlang/toit/releases/download/$(VERSION)/firmware-esp32.gz
WIFI_CREDENTIALS := {"wifi.ssid":"<my-ssid>","wifi.password":"<my-password>"}

.PHONY: all
all: ota.bin

# Always repuild the firmware envelope since we modify it.
.PHONY: firmware.envelope
firmware.envelope: firmware.envelope.gz
	gunzip -c firmware.envelope.gz > firmware.envelope

firmware.envelope.gz:
	curl -L -o $@ $(ENVELOPE_URL)

%.snapshot: %.toit
	$(TOIT_EXE) compile --snapshot -O2 -o $@ $<

ota.bin: validate.snapshot firmware.envelope
	$(TOIT_EXE) tool firmware -e firmware.envelope container install validate validate.snapshot
	$(TOIT_EXE) tool firmware -e firmware.envelope property set wifi '$(WIFI_CREDENTIALS)'
	$(TOIT_EXE) tool firmware -e firmware.envelope extract --format=binary -o ota.bin

ota-encrypted.bin: ota.bin
	$(TOIT_EXE) run encrypt.toit $< $@

.PHONY: serve
serve: ota-encrypted.bin
	python3 -m http.server 8000

.PHONY: version
version:
	@echo $(VERSION)

.PHONY: clean
clean:
	rm -f *.snapshot *.bin firmware.envelope firmware.envelope.gz
