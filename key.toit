// Copyright (C) 2024 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the LICENSE_BSD0 file.

import crypto.sha1

IV-SIZE ::= 16
KEY-SIZE ::= 16
BLOCK-SIZE ::= 16

SECRET ::= "my secret"
KEY ::= (sha1.sha1 SECRET)[..KEY-SIZE]
