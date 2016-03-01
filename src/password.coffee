bcrypt = require 'bcrypt'
Promise = require 'bluebird'
Crypto = require './crypto'
zxcvbn = require 'zxcvbn'

class Password
  @iteration: 12
  @hash: (password, cb) ->
    bcrypt.hash password, @iteration, (err, res) ->
      if err
        cb err
      else
        cb null, res
  @compare: (password, hash, cb) ->
    bcrypt.compare password, hash, cb
  @genMasterKey: (type, password, hash, cb) ->
    @compare password, hash, (err, res) ->
      if err
        cb err
      else
        Crypto.createKey type, password, hash, cb
  @entropy: (password) ->
    zxcvbn password

Promise.promisifyAll Password.prototype
Promise.promisifyAll Password

module.exports = Password

