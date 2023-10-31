import express from 'express'

const router = express.Router()

router.post('/send_message', (_req, res, _next) => {
  res.json({ping: 'send'})
})

router.post('/receive_message', (_req, res, _next) => {
  res.json({ping: 'receive'})
})

export default router