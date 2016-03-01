Crypto = require '../src/crypto'
{ assert } = require 'chai'

describe 'crypto test', ->

  crypto = null
  it 'can create crypto', ->
    crypto = Crypto()
  password = 'this is a password'
  data =
    foo: 1
    bar: 2
    stuff:
      this_is: 'top_secret_to_be_encrypted'

  encrypted = null

  it 'can encrypt', (done) ->
    crypto.encrypt 'aes192', password, data, (err, res) ->
      if err
        done err
      else
        encrypted = res
        done null

  it 'can decrypt', (done) ->
    crypto.decrypt password, encrypted, (err, res) ->
      if err
        done err
      else
        try
          assert.deepEqual data, res
          done null
        catch e
          done e

  it 'can encrypt and decrypt', (done) ->
    
    Crypto.encrypt 'aes256', password, data, (err, encrypted) ->
      if err
        done err
      else
        Crypto.decrypt password, encrypted, (err, decrypted) ->
          if err
            done err
          else
            try
              assert.deepEqual data, decrypted
              done null
            catch e
              done e

  it 'can hash', (done) ->
    Crypto.hash 'sha256', 'password:' + password, (err, hash) ->
      if err
        done err
      else
        console.log 'hash', hash
        done null

