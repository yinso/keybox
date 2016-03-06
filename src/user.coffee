###
# User
#
# the full user object is encrypted.
###
Crypto = require './crypto'
Password = require './password'
Promise = require 'bluebird'

class User
  @prefix: 'user:'
  @encType: 'aes256'
  @hashType: 'sha256'
  @deriveKey: (username, password, cb) ->
    Crypto.createKey @encType, @prefix + username + password, username, (err, buffer) ->
      if err
        cb err
      else
        cb null, buffer.toString 'hex'
  @deriveHash: (password, salt, cb) ->
    Crypto.createKey @encType, password, salt, (err, buffer) ->
      if err
        cb err
      else
        cb null, buffer.toString 'hex'
  @deserialize: (serialized, username, password, cb) ->
    @deriveHashAsync password, username
      .then (hash) ->
        console.log 'User.deserialize:HASH', hash
        key = 'user:' + username + ',' + hash
        Crypto.decryptAsync(key, serialized)
      .then (res) ->
        cb null, User(JSON.parse res)
      .catch cb
  constructor: (options = {})->
    if not (@ instanceof User)
      return new User arguments...
    # user must have the following property.
    console.log 'User.ctor', options
    for key, val of options
      @[key] = val
  initPassword: (password, cb) ->
    if @hasOwnProperty('hash')
      return cb new Error("User.initPassword:alreadyInited")
    @_setPassword password, cb
  _setPassword: (password, cb) ->
    self = @
    User.deriveHashAsync password, self.username
      .then (hash) ->
        self.hash = hash
        cb null
      .catch cb
  changePassword: (password, newPassword, confirm, cb) ->
    self = @
    if password == newPassword
      return cb new Error("User.changePassword:samePassword")
    if newPassword != confirm
      return cb new Error("User.changePassword:newPasswordNotMatch")
    User.deriveHashAsync password, self.username
      .then (hash) ->
        if self.hash == hash
          self._setPassword newPassword, cb
        else
          throw new Error("User.changePassword:incorrectPassword")
      .catch cb
  serializeKey: (cb) ->
    Crypto.hash User.hashType, 'user:' + @username, cb
  serialize: (cb) ->
    # we will assume the hash already exists in the system...
    console.log 'User.serialize:HASH', @hash
    password = 'user:' + @username + ',' + @hash
    data = JSON.stringify 
      username: @username
      hash: @hash
      masterKey: @masterKey
      keys: @keys or {}
    Crypto.encrypt User.encType, password, data, cb
    # this one is going to be a bit troublesome...
    # we don't want to maintain password, but in order to write anything in here
    # we will need a password... hmmm.... not as easy as I thought...
    # 
    # what are we going to do?
    # we are going to 
# key
    # 

Promise.promisifyAll User
Promise.promisifyAll User.prototype

module.exports = User

