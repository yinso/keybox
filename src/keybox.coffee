Promise = require 'bluebird'
User = require './user'
Storage = require './storage'

class Keybox
  @initialize: (options, cb) ->
    keybox = Keybox options
    keybox.connect cb
  constructor: (options) ->
    if not (@ instanceof Keybox)
      return new Keybox arguments...
    @options = options
  connect: (cb) ->
    self = @
    Storage.initialize self.options.filePath, (err, conn) ->
      if err
        cb err
      else
        self.conn = conn
        cb null, self
  createUser: (options, cb) ->
    user = User options, @conn
    cb null, user


Promise.promisifyAll Keybox
Promise.promisifyAll Keybox.prototype

module.exports = Keybox

