import {Router} from 'express'


const router = Router()

const modelUrl = process.env.MODEL_URL ?? '10.0.10.1'

router.post('/ping', (_req, res, _next) => {
  res.json({ping: 'ok'})
})

router.post('/send', async (req, res, _next) => {
  try {
    const {body} = req
    if (typeof body !== 'string' && body.length) {
      const {data} = await got.post(modelUrl, {body: {prompt: body}}).json()
      return res.status(200).send(data)
    }

    return res.sendStatus(201)
  } catch (e) {
    res.sendStatus(403)
  }
})

export default router