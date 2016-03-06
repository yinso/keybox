User = require '../src/user'

describe 'user test', ->
  username = 'test'
  password = 'this is a password'

  user = null

  it 'can create user', (done) ->
    user = User { username: username }
    done null
  
  it 'can init password', (done) ->
    user.initPassword password, (err) ->
      done err

  newPassword = 'this is the new password'

  it 'cannot init password second time', (done) ->
    user.initPassword newPassword, (err) ->
      console.log 'init password second time', arguments
      if err
        done null
      else
        done new Error("User.initPassword is called second time")

  it 'can change password', (done) ->
    user.changePassword password, newPassword, newPassword, done

  it 'can change password back', (done) ->
    user.changePassword newPassword, password, password, done

  key = null

  it 'can derive key', (done) ->
    User.deriveKey username, password, (err, res) ->
      if err
        done err
      else
        key = res
        console.log 'derived.key', key
        done null

  serialized = null

  it 'can serialize', (done) ->

    user.serialize (err, res) ->
      if err
        done err
      else
        console.log 'user.serialize', res
        serialized = res
        done null

  it 'can deserialize', (done) ->
    User.deserialize serialized, username, password, (err, res) ->
      if err
        done err
      else
        console.log 'user.deserialize', res
        done null


