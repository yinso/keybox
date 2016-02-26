Storage = require '../src/storage'
{ assert } = require 'chai'
fs = require 'fs'

describe 'storage test', ->
  
  storage = null
  path = './test.keybox'

  it 'can create storage', (done) ->
    Storage.initialize path, (err, res) ->
      if err
        done err
      else
        storage = res
        done null
  user_id = 0
  key = 'test-key'
  val = { foo: 1, bar: 2, stuff: [1, 2, 3] }

  it 'can storage key/object', (done) ->
    storage.set user_id, key, val, done

  it 'can retrieve value', (done) ->
    storage.get user_id, key, (err, res) ->
      if err
        done err
      else
        assert.deepEqual res, val
        done null

  it 'can delete key', (done) ->
    storage.delete user_id, key, (err, res) ->
      if err
        done err
      else
        done null

  user = null

  it 'can create user', (done) ->
    storage.createUser 'test1', 'this is a test', (err, res) ->
      if err
        done err
      else
        user = res
        done null

  it 'can set via user', (done) ->
    user.set 'test-key', { hello: 'world' }, done

  it 'can get via user', (done) ->
    user.get 'test-key', (err, res) ->
      if err
        done err
      else
        try
          assert.deepEqual res, { hello: 'world' }
          done null
        catch e
          done e
 
  it 'can delete via user', (done) ->
    user.delete 'test-key', done

  it 'can close storage', (done) ->
    storage.close done

  it 'can destroy storage', (done) ->
    storage.destroy done

