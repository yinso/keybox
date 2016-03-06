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
    keybox.createUser username, password, { email: email }, (err, val) ->
      if err
        done err
      else
        user = val
        done null

  it 'can login', (done) ->
    keybox.login username, password, (err, val) ->
      if err
        done err
      else
        user = val
        done null

  newPassword = 'this is the new password try it'

  it 'can change password', (done) ->
    keybox.changePasswordAsync username, password, newPassword, newPassword
      .then ->
        keybox.loginAsync username, password
          .then ->
            throw new Error("old password still works!")
          .catch (err) ->
            return
      .then ->
        keybox.loginAsync username, newPassword
      .then ->
        user = keybox.currentUser
        done null
      .catch done
    

  it 'can remove file', (done) ->
    fs.unlink filePath, done

