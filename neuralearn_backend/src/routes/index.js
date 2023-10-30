import express from 'express'
import messagesRouter from './messages/index.js'

const router = express.Router()

router.get('/', (_req, res, _next) => {
  res.redirect("/index.html")
})

router.use('/', messagesRouter)

export default router