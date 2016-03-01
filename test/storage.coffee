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
  key = 'test-key'
  val = { foo: 1, bar: 2, stuff: [1, 2, 3] }

  it 'can storage key/object', (done) ->
    storage.set key, val, done

  it 'can retrieve value', (done) ->
    storage.get key, (err, res) ->
      if err
        done err
      else
        assert.deepEqual res, val
        done null

  it 'can delete key', (done) ->
    storage.delete key, done

  it 'can close storage', (done) ->
    storage.close done

  it 'can destroy storage', (done) ->
    storage.destroy done

