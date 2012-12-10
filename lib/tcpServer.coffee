express = require 'express'
util = require 'util'

module.exports = (sessionStorage, logStorage) ->
	app = express()
	app.use express.bodyParser()
	app.use app.router
	
	app.post '/sessions', (req, res) ->
		p = req.body
		
		util.log util.inspect p
		sessionStorage.create p.app, p.branch, p.type, (o) ->
			res.json o
		
	app.get '/session/:app/:branch', (req, res) ->
		
		sessionStorage.getSessions req.params.app, req.params.branch, (sessions) ->
			ids = []
			map = {}
				
			for session in sessions
				ids.push session.uuid 
				map[session.uuid] = session
				
				
			logStorage.find ids, (data) ->
				# out = []
				for item in data
					item.type = map[item.uuid].type
					# out.push ite
				
				res.json data
			
			# res.json ids
			


			# sessionStorage.resolveIds ids, (xx) ->
			# 	res.json xx
		# 		
		# ids = ['3b41c023-34b2-4bbb-a777-b50a627d7963']
		# sessionStorage.resolveIds ids, (xx) ->
		# 	sessionStorage.
		# 	# util.log util.inspect arguments
		# 	res.json xx
		# 
		# logStorage.find (data) ->
		# 	res.json data

			
	app.listen 5000
	console.log "web listening #{5000}"
