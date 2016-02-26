Promise = require 'bluebird'
class User
  constructor: (storage, props) ->
    if not (@ instanceof User)
      return new User storage, props
    @storage = storage
    @props = props
  get: (key, cb) ->
    @storage.get @props.id, key, cb
  set: (key, val, cb) ->
    @storage.set @props.id, key, val, cb
  delete: (key, cb) ->
    @storage.delete @props.id, key, cb

Promise.promisifyAll User

module.exports = User

