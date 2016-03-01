# Keybox - A Password Manager in Node.JS.

A password manager in node.js. This is not yet operational.

## Encryption Methods

Keybox uses the following ciphers for symmetric encryption.

* aes256

It uses the following for master password hash.

* bcrypt

## Design

Keybox deals with data level encryptions (rather than file-level) so the storage file itself isn't encrypted (unless the storage is a flatfile). This allows it to work with storage mechanisms outside of keybox control, like database servers.

All data under the management of keybox are encrypted, including - user profiles, keys, and the values. The only thing that can unlock the data is the master password supplied by the user at the point of creation. A forget password mechanism requires another profile having access to the underlying master key.

The user object contains the master key that's used to unlock the keys owned by the user, and each of the keys unlocked has its own encryption keys used for encrypting the values. This design allows for more protection on the data in the case that the master key isn't compromised.

Once master password is entered, it is validated and unlocks the User profile, which provides the master key that can be used to unlock the keys. Each of the keys then contains value keys that can be used to unlock the values.

Currently keybox doesn't deal with memory-level attack, i.e. the master password is retained in JavaScript GC until freed. This can be remedied in the future with a native module that overwrites the password variable.



