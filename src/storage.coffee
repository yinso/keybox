# storage uses sqlite by default
fs = require 'fs'
path = require 'path'
DBI = require 'easydbi'
require 'easydbi-sqlite'
Promise = require 'bluebird'

class Storage
  @initialize: (filePath, cb) ->
    setupName = 'storage:' + filePath
    if not DBI.hasSetup setupName
      DBI.setup setupName,
        type: 'sqlite'
        options:
          filePath: filePath
    DBI.connect setupName, (err, conn) ->
      if err
        cb err
      else
        storage = new Storage filePath, conn
        storage.loadSchema cb
  constructor: (filePath, conn) ->
    if not (@ instanceof Storage)
      new Storage arguments...
    @filePath = filePath
    @conn = conn
  loadSchema: (cb) ->
    self = @
    conn = self.conn
    conn.loadScript path.join(__dirname, '../schema/sqlite3.sql'), true, (err) ->
      if err
        cb err
      else
        cb null, self
  set: (key, val, cb) ->
    conn = @conn
    self = @
    conn.beginAsync()
      .then ->
        conn.queryAsync 'select 1 from keyvals where key = $key', { key : key }
      .then (rows) ->
        serialized = self.serialize(val)
        if rows.length == 0
          conn.execAsync 'insert into keyvals (key, value) values ($key, $value)', { key: key, value: serialized }
        else
          conn.execAsync 'update keyvals set value = $value where key = $key', { key: key, value: serialized }
      .then ->
        conn.commitAsync()
      .then ->
        cb null
      .catch (e) ->
        conn.rollback ->
          cb e
  get: (key, cb) ->
    conn = @conn
    self = @
    conn.queryAsync 'select value from keyvals where key = $key', { key : key }
      .then (rows) ->
        if rows.length == 0
          return cb null, undefined
        else
          return cb null, self.deserialize(rows[0].value)
      .catch cb
  serialize: (val) ->
    JSON.stringify val
  deserialize: (val) ->
    JSON.parse val
  delete: (key, cb) ->
    conn = @conn
    conn.execAsync 'delete from keyvals where key = $key', { key : key }
      .then (rows) ->
        return cb null
      .catch cb
  close: (cb) ->
    @conn.disconnect cb
  destroy: (cb) ->
    fs.unlink @filePath, cb

Promise.promisifyAll Storage
Promise.promisifyAll Storage.prototype

module.exports = Storage

