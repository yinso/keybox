crypto = require 'crypto'
Promise = require 'bluebird'

class Crypto
  @encrypt: (type, password, data, cb) ->
    c = new Crypto()
    c.encrypt type, password, data, cb
  @decrypt: (type, password, encrypted, cb) ->
    c = new Crypto()
    c.decrypt password, encrypted, cb
  constructor: (options = {}) ->
    if not (@ instanceof Crypto)
      return new Crypto(options)
    @saltSize = options.saltSize or 32
    @keyDerivationPass = options.keyDerivationPass or 1024
  ivSize: (type) ->
    switch type
      when 'aes128', 'aes192', 'aes256'
        16
      when 'aes192'
        24
      when 'aes256'
        32
      else
        throw new Error("Crypto.ivSize:unknown_cipher: #{type}")
  keySize: (type) ->
    switch type
      when 'aes128'
        16
      when 'aes192'
        24
      when 'aes256'
        32
      else
        throw new Error("Crypt.keySize:unknown_cipher: #{type}")
  createIV: (type, cb) ->
    try
      size = @ivSize type
      crypto.randomBytes size, cb
    catch e
      cb e
  createSalt: (cb) ->
    crypto.randomBytes @saltSize, cb
  createKey: (type, password, salt, cb) ->
    try
      keyLength = @keySize type
      crypto.pbkdf2 password, salt, @keyDerivationPass, keyLength, cb
    catch e
      cb e
  encrypt: (type, password, data, cb) ->
    self = @
    self.createSaltAsync()
      .then (salt) ->
        self.createKeyAsync(type, password, salt)
          .then (key) ->
            self.createIVAsync(type)
              .then (iv) ->
                self._encrypt type, salt, key, iv, data, cb
      .catch cb
  _encrypt: (type, salt, key, iv, data, cb) ->
    cipher = crypto.createCipheriv type, key, iv
    res = []
    cipher.on 'readable', ->
      data = cipher.read()
      if data
        res.push data.toString('hex')
    cipher.on 'end', ->
      cb null, [ type, salt.toString('hex'), iv.toString('hex'), res.join('') ].join(':')
    cipher.write JSON.stringify(data)
    cipher.end()
  decrypt: (password, encrypted, cb) ->
    [ type, salt , iv , data ] = encrypted.split ':'
    salt = new Buffer salt, 'hex'
    iv = new Buffer iv, 'hex'
    self = @
    self.createKeyAsync(type, password, salt)
      .then (key) ->
        self._decrypt type, key, iv, data, cb
      .catch cb
  _decrypt: (type, key, iv, data, cb) ->
    decipher = crypto.createDecipheriv type, key, iv
    res = []
    decipher.on 'readable', ->
      data = decipher.read()
      if data
        res.push data.toString('utf8')
    decipher.on 'end', ->
      try
        cb null, JSON.parse(res.join(''))
      catch e
        cb e
    decipher.write data, 'hex'
    decipher.end()

Promise.promisifyAll Crypto
Promise.promisifyAll Crypto.prototype

module.exports = Crypto

