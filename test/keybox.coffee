Keybox = require '../src/keybox'
fs = require 'fs'

describe 'keybox test', ->

  keybox = null
  filePath = './test.kbx'
  it 'can init', (done) ->
    Keybox.initialize {filePath: filePath}, (err, self) ->
      if err
        done err
      else
        keybox = self
        done null

  username = 'test'
  email = 'test@test.com'
  password = 'this is a test password'

  user = null

  it 'can create user', (done) ->
    keybox.createUser { username: username, email: email, password: password }, (err, val) ->
      if err
        done err
      else
        user = val
        done null

  
  
  it 'can remove file', (done) ->
    fs.unlink filePath, done

