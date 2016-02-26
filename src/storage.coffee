# storage uses sqlite by default
fs = require 'fs'
path = require 'path'
DBI = require 'easydbi'
require 'easydbi-sqlite'
Promise = require 'bluebird'
User = require './user'
Password = require './password'

class Storage
  @initialize: (path, cb) ->
    if not DBI.hasSetup 'storage'
      DBI.setup 'storage',
        type: 'sqlite'
        options:
          filePath: path
    DBI.connect 'storage', (err, conn) ->
      if err
        cb err
      else
        storage = new Storage path, conn
        storage.loadSchema cb
  constructor: (path, conn) ->
    if not (@ instanceof Storage)
      new Storage arguments...
    @path = path
    @conn = conn
  loadSchema: (cb) ->
    self = @
    conn = self.conn
    conn.loadScript path.join(__dirname, '../schema/sqlite3.sql'), true, (err) ->
      if err
        cb err
      else
        cb null, self
  createUser: (username, password, cb) ->
    conn = @conn
    self = @
    Password.hashAsync password
      .then (hash) ->
        conn.execAsync 'insert into users (username, hash) values ($username, $hash)', { username: username, hash: hash }
      .then ->
        conn.queryOneAsync 'select * from users where username = $username', { username: username }
      .then (row) ->
        console.log 'Storage.createUser', username, row
        cb null, new User(self, row)
      .catch cb
  set: (user_id, key, val, cb) ->
    conn = @conn
    conn.beginAsync()
      .then ->
        conn.queryAsync 'select 1 from keyvals where user_id = $user_id and key = $key', { user_id : user_id , key : key }
      .then (rows) ->
        if rows.length == 0
          conn.execAsync 'insert into keyvals (user_id, key, value) values ($user_id , $key, $value)', { user_id: user_id, key: key, value: JSON.stringify(val) }
        else
          conn.execAsync 'update keyvals set value = $value where user_id = $user_id and key = $key', { user_id: user_id, key: key, value: JSON.stringify(val) }
      .then ->
        conn.commitAsync()
      .then ->
        cb null
      .catch (e) ->
        conn.rollback ->
          cb e
  get: (user_id, key, cb) ->
    conn = @conn
    conn.queryAsync 'select value from keyvals where key = $key', { key : key }
      .then (rows) ->
        if rows.length == 0
          return cb null, undefined
        else
          return cb null, JSON.parse(rows[0].value)
      .catch cb
  delete: (user_id, key, cb) ->
    conn = @conn
    conn.execAsync 'delete from keyvals where user_id = $user_id and key = $key', { user_id: user_id, key: key }
      .then ->
        cb null
      .catch cb
  close: (cb) ->
    @conn.disconnect cb
  destroy: (cb) ->
    fs.unlink @path, cb

Promise.promisifyAll Storage
Promise.promisifyAll Storage.prototype

module.exports = Storage

