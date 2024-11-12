// Copyright (C) 2024 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the LICENSE_BSD0 file.

import crypto
import crypto.aes
import host.file

import .key

main args:
  data := file.read-contents args[0]
  if (data.size % BLOCK-SIZE) != 0:
    throw "data must be a multiple of $BLOCK-SIZE bytes"

  iv := crypto.random --size=IV-SIZE
  key := KEY

  encrypted := aes.AesCbc.encryptor key iv
  encrypted-data := encrypted.encrypt data

  file.write-contents --path=args[1] (iv + encrypted-data)
