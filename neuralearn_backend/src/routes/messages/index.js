import {Router} from 'express'


const router = Router()

const modelUrl = `${process.env.MODEL_URL ?? '10.0.10.1'}:8080`

router.get('/ping', (_req, res, _next) => {
  res.json({ping: 'ok'})
})

router.post('/send', async (req, res, _next) => {
  try {
    const {body} = req
    if (typeof body !== 'string' && body.length) {
      const {data} = await got.post(`http://${modelUrl}/api/v1/model/v1/send`, {body: {prompt: body}}).json()
      return res.status(200).send(data)
    }

    return res.sendStatus(201)
  } catch (e) {
    res.sendStatus(403)
  }
})

export default router