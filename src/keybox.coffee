Promise = require 'bluebird'
User = require './user'
Storage = require './storage'
_ = require 'lodash'

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
  createUser: (username, password, args, cb) ->
    conn = @conn
    user = User _.extend { username: username }, args
    user.initPasswordAsync password
      .then ->
        user.serializeAsync()
      .then (serialized) ->
        User.deriveKeyAsync username, password
          .then (key) ->
            conn.setAsync key, serialized
      .then ->
        cb null
      .catch cb
  login: (username, password, cb) ->
    conn = @conn
    self = @
    User.deriveKeyAsync username, password
      .then (key) ->
        conn.getAsync key
      .then (serialized) ->
        if serialized
          User.deserializeAsync serialized, username, password
        else
          throw new Error("Keybox.login:USER_NOT_FOUND: #{options.username}")
      .then (deserialized) ->
        self.currentUser = User deserialized
        cb null, self.currentUser
      .catch cb
  changePassword: (username, password, newPassword, confirm, cb) ->
    self = @
    self.loginAsync username, password
      .then (user) ->
        user.changePasswordAsync password, newPassword, confirm
          .then ->
            user.serializeAsync()
          .then (serialized) ->
            User.deriveKeyAsync username, newPassword
              .then (newKey) ->
                self.conn.setAsync newKey, serialized
                  .then ->
                    User.deriveKeyAsync username, password
                  .then (key) ->
                    if key != newKey
                      self.conn.deleteAsync key
                    else
                      return
      .then ->
        cb null
      .catch cb
  logout: (cb) ->
    delete @currentUser
  set: (key, val, cb) ->
    if not @currentUser
      return cb new Error("keybox.set:NOT_LOGGED_IN")
    conn = @conn
    
Promise.promisifyAll Keybox
Promise.promisifyAll Keybox.prototype

module.exports = Keybox

