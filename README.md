# Encrypted OTA

This is a simple example of how to encrypt an OTA update file for the ESP32.

The device has a symmetric key stored in the flash memory. The same key is used to
encrypt the firmware file before it is sent to the device. The device then decrypts
the file and writes it to the OTA partition.

Since the flash memory is encrypted, attackers cannot extract the firmware file.

## Note

This example has not been verified by a security expert. It should make it
significantly harder for attackers to extract the firmware file, but without
a proper security audit, developers should not assume that the firmware file
is completely secure.

## Tutorial

This example is based on the [OTA tutorial](https://docs.toit.io/tutorials/misc/ota).
Use the tutorial to learn how to set up the OTA update process.
