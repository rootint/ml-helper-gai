import requestID from 'express-request-id'
import createHttpError from 'http-errors'
import express from 'express'
import path from 'path'
import ejs from 'ejs'
import morgan from 'morgan'
import dotenv from 'dotenv'

import indexRouter from './routes/index.js'

import {fileURLToPath} from 'url'

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config()

// const express = require('express')
// const path = require('path')
// const ejs = require('ejs')
// const morgan = require('morgan')

const addRequestId = requestID({setHeader: false})
morgan.token('id', req => req.id.split('-')[0])

// const indexRouter = require('./routes/index')

const app = express()

app.engine('html', ejs.renderFile);
app.set('view engine', 'html');
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(express.static(path.join(__dirname, 'public')))

app.use(addRequestId)
app.use(
  morgan(
    "[:date[iso] #:id] Started :method :url for :remote-addr",
    {
      immediate: true
    }
  )
)

app.use('/', indexRouter)

app.use((_req, _res, next) => {
  next(createHttpError(404))
})

app.use((err, req, res, _next) => {
  res.locals.message = err.message
  res.locals.error = req.app.get('env') === 'development' ? err : {}

  res.status(err.status || 500)
  res.send('Internal Error')
})

const PORT = 80
const HOST = '0.0.0.0'

const server = app.listen(PORT, HOST, () => {
  console.log(`Running on http://${HOST}:${PORT}`);
});

process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

function shutDown() {
  console.log('Received kill signal, shutting down gracefully');
  server.close(() => {
      console.log('Closed out remaining connections');
      process.exit(0);
  });

  setTimeout(() => {
      console.error('Could not close connections in time, forcefully shutting down');
      process.exit(1);
  }, 2_000);
}