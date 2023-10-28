const createError = require('http-errors')
const express = require('express')
const path = require('path')
const ejs = require('ejs')

const indexRouter = require('./routes/index')

const app = express()

app.engine('html', ejs.renderFile);
app.set('view engine', 'html');
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(express.static(path.join(__dirname, 'public')))

app.use('/', indexRouter)

app.use((_req, _res, next) => {
  next(createError(404))
})

app.use((err, req, res, _next) => {
  res.locals.message = err.message
  res.locals.error = req.app.get('env') === 'development' ? err : {}

  res.status(err.status || 500)
  res.send('Internal Error')
})

const PORT = 80
const HOST = '0.0.0.0'
app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});
