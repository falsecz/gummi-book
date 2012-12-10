dgram = require "dgram"

module.exports = (sessionStorage, logStorage) ->
	server = dgram.createSocket "udp4"

	server.on "listening", () ->
		address = server.address()
		console.log("server listening " + address.address + ":" + address.port);

	server.on "message", (msg, rinfo) ->
		msg = msg.toString()
		if msg
			o = 
				time: msg[0...16]
				uuid: msg[17...53]
				message: msg.substring 54
			o.message = o.message.trim()
			
		logStorage.log o.time, o.uuid, o.message
		# console.log o.time + "" + o.uuid + " " + o.message

	server.bind(7777)
	
	