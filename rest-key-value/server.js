#!/usr/bin/env node

import { createClient } from 'redis'
import express from 'express'

// config map
const config = {
  PORT: process.env.PORT || 3000,
  REDIS_HOST: process.env.REDIS_HOST || 'localhost',
  REDIS_PORT: process.env.REDIS_PORT || 6379,
}

async function main({ config }) {
  // express server
  const app = express()

  // redis client
  const redis = createClient({
    socket: {
      host: config.REDIS_HOST,
      port: config.REDIS_PORT,
    }
  })
  await redis.connect()

  // routes
  app.get('/', (req, res) => {
    res.json({
      status: 'OK',
      message: `Hello from ${process.env.npm_package_name}`
    })
  })

  app.get('/data/:key', async (req, res) => {
    const reply = await redis.get(req.params.key)
    res.json({
      status: 'OK',
      data: reply
    })
  })

  app.put('/data/:key/:value', async (req, res) => {
    await redis.set(req.params.key, req.params.value)
    res.json({
      status: 'OK'
    })
  })

  // start server
  app.listen(config.PORT, () => {
    console.log(`Server is listening at http://localhost:${config.PORT}`)
  })
}

main({config})
