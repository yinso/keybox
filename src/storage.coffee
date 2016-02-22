# storage uses sqlite by default
fs = require 'fs'
path = require 'path'
DBI = require 'easydbi'
require 'easydbi-sqlite'
Promise = require 'bluebird'

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
  set: (key, val, cb) ->
    conn = @conn
    conn.beginAsync()
      .then ->
        conn.queryAsync 'select 1 from keyvals where key = $key', { key : key }
      .then (rows) ->
        if rows.length == 0
          conn.execAsync 'insert into keyvals (key, value) values ($key, $value)', { key: key, value: JSON.stringify(val) }
        else
          conn.execAsync 'update keyvals set value = $value where key = $key', { key: key, value: JSON.stringify(val) }
      .then ->
        conn.commitAsync()
      .then ->
        cb null
      .catch (e) ->
        conn.rollback ->
          cb e
  get: (key, cb) ->
    conn = @conn
    conn.queryAsync 'select value from keyvals where key = $key', { key : key }
      .then (rows) ->
        if rows.length == 0
          return cb null, undefined
        else
          return cb null, JSON.parse(rows[0].value)
      .catch cb
  close: (cb) ->
    @conn.disconnect cb
  destroy: (cb) ->
    fs.unlink @path, cb

Promise.promisifyAll Storage
Promise.promisifyAll Storage.prototype

module.exports = Storage

