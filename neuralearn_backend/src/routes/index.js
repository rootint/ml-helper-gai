const express = require('express')
const messagesRouter = require('./messages/index')

const router = express.Router()

router.get('/', (_req, res, _next) => {
  res.redirect("/index.html")
})

router.use('/', messagesRouter)

module.exports = router
