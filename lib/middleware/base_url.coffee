url = require 'url'

module.exports = baseUrlMiddleware = (req, res, next) ->
  res.locals.baseUrl = url.format
    host: req.headers.host
    protocol: req.protocol
  next()
