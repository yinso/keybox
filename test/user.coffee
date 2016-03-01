User = require '../src/user'

describe 'user test', ->
  username = 'test'
  password = 'this is a password'

  user = null

  it 'can create user', (done) ->
    user = User { username: username }
    done null
  
  it 'can set password', (done) ->
    user.setPassword password, (err) ->
      done err

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


