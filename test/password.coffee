Password = require '../src/password'
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

