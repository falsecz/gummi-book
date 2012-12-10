util = require 'util'
nodeUuid = require 'node-uuid'
sqlite3 = require('sqlite3').verbose()


class SessionStorage 
	getSessions: (app, branch, done) =>
		@db.all "SELECT * FROM sessions WHERE app = $app AND branch = $branch", {
			$app: app
			$branch: branch
		}, (err, rows) ->
			done rows

	getId: (app, branch, type, done) =>
		@db.all "SELECT * FROM sessions WHERE app = $app AND branch = $branch AND $type = type", {
			$app: app
			$branch: branch
			$type: type
		}, (err, rows) ->
			return done rows[0].uuid if rows?.length
			done null
	
	resolveIds: (uuids, done) =>
		r = '"' + uuids.join('","') + '"'
		console.log r
		@db.all "SELECT * FROM sessions WHERE uuid IN (#{r})",(err, rows) ->
			done rows
		
			
	create: (app, branch, type, done) =>
		
		@getId app, branch, type, (uuid) =>
			unless uuid
				uuid = nodeUuid.v4()

				@db.run "INSERT INTO sessions (uuid, app, branch, type) VALUES ($uuid, $app, $branch, $type)", {
					$uuid: uuid, $app: app, $branch: branch, $type: type
				}

			done
				app: app
				branch: branch
				type: type
				uuid: uuid

	init: (done) ->
		@db = new sqlite3.Database('sessions.db')
		@db.run "CREATE TABLE sessions (uuid TEXT, app TEXT, branch TEXT, type TEXT, UNIQUE(app, branch, type) ON CONFLICT IGNORE)", ->
			done()

	
class LogStorage
	init: (done) ->
		# @db = new sqlite3.Database(':memory:')
		@db = new sqlite3.Database('temp.db')
		util = require 'util'
		@db.run "CREATE TABLE logs (ts INTEGER, uuid TEXT, msg TEXT)", ->
			done()
		
	log: (ts, uuid, msg) ->
		@db.run "INSERT INTO logs (ts, uuid, msg) VALUES ($ts, $uuid, $msg)", {$ts: ts, $uuid: uuid, $msg: msg}, () ->
			# util.log util.inspect arguments
		 
	
	find: (ids, done) ->
		r = '"' + ids.join('","') + '"'
		util.log r
		@db.all "SELECT * FROM logs WHERE uuid IN (#{r}) ORDER BY ts desc LIMIT 20", (err, rows) ->
			done rows
	
		
	
	
sessionStorage = new SessionStorage
logStorage = new LogStorage

sessionStorage.init ->
	logStorage.init ->
		
		require('./lib/udpServer')(sessionStorage, logStorage)
		require('./lib/tcpServer')(sessionStorage, logStorage)


