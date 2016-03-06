Password = require '../src/password'
Crypto = require '../src/crypto'
bcrypt = require 'bcrypt'
{ assert } = require 'chai'

describe 'password test', ->

  pass = 'this is a password'

  hash = null

  it 'can hash password', (done) ->
    Password.hash pass, (err, res) ->
      if err
        done err
      else
        hash = res
        console.log 'Password.hash =>', hash
        done null

  it 'can compare password', (done) ->
    Password.compare pass, hash, done

  it 'can generate master key', (done) ->
    Password.genMasterKey 'aes256', pass, hash, (err, res) ->
      if err
        done err
      else
        console.log 'master.key', res
        done null

  it 'can estimate password entropy', (done) ->
    res = Password.entropy pass
    console.log 'password entropy', res
    done null

  salt = null
  fixedSalt = null
  it 'can create salt', (done) ->
    Crypto.createKey 'aes256', pass, '', (err, res) ->
      if err
        done err
      else
        salt = res.toString 'hex'
        fixedSalt = '$2a$12$' + salt
        console.log 'crypto.salt', fixedSalt
        done null

  
  it 'can craete salt', (done) ->
    bcrypt.genSalt 12, (err, res) ->
      if err
        done err
      else
        console.log 'bcrypt.gen.salt', res
        done null

  val = '$2a$12$7ce070a46f5443a91ab59OJHvLFO6a.sq7cq8uZ2NjI9IRh.GjaTi'
  fixedHash = null
  it 'can use fixed salt', (done) ->
    bcrypt.hash pass, "$2a$12$" + salt, (err, res) ->
      if err
        done err
      else
        console.log 'bcrypt.fixed.salt', res, val == res
        fixedHash = res
        done null

  it 'can compare against the fixed salt', (done) ->
    bcrypt.compare pass, fixedHash, (err, res) ->
      if err
        done err
      else
        console.log 'bcrypt.compare.result', res
        done null



