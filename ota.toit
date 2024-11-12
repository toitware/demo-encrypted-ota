// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the LICENSE_BSD0 file.

import crypto.sha1
import crypto.aes
import http
import io
import net
import system.firmware

import .key

IP ::= "192.168.88.148"
UPDATE-URL := "http://$IP:8000/ota-encrypted.bin"

class DecryptingReader:
  wrapped_/io.Reader
  buffered_/ByteArray? := null
  decryptor_/aes.Aes

  constructor .wrapped_ --key/ByteArray --initialization-vector/ByteArray:
    decryptor_ = aes.AesCbc.decryptor key initialization-vector

  read -> ByteArray?:
    while true:
      data := wrapped_.read
      if not data:
        if buffered_:
          throw "incomplete data"
        return null

      if buffered_:
        data = buffered_ + data
        buffered_ = null

      incomplete-size := data.size % BLOCK-SIZE
      if incomplete-size != 0:
        buffered_ = data[data.size - incomplete-size..]
        data = data[..data.size - incomplete-size]

      if data.size == 0:
        continue

      return decryptor_.decrypt data

install-firmware reader/io.Reader -> none:
  firmware-size := reader.content-size
  print "installing firmware with $firmware-size bytes"
  written-size := 0
  writer := firmware.FirmwareWriter 0 (firmware-size - IV-SIZE)
  key := KEY
  initialization-vector := reader.read-bytes IV-SIZE
  decrypting-reader := DecryptingReader reader
      --key=key
      --initialization-vector=initialization-vector
  try:
    last := null
    while data := decrypting-reader.read:
      written-size += data.size
      writer.write data
      percent := (written-size * 100) / firmware-size
      if percent != last:
        print "installing firmware with $firmware-size bytes ($percent%)"
        last = percent
    writer.commit
    print "installed firmware; ready to update on chip reset"
  finally:
    writer.close

main:
  network := net.open
  client := http.Client network
  try:
    response := client.get --uri=UPDATE-URL
    install-firmware response.body
  finally:
    client.close
    network.close
  firmware.upgrade
