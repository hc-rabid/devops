const express = require('express')
const { createProxyMiddleware } = require('http-proxy-middleware')

const app = express()

const PORT = 3000
const HOST = "localhost"
const API_SERVICE_URL = "http://localhost:4000"

app.get('/info', (req , res, next) => {
  res.send('This is a proxy service which proxies to Holidays API by Raymond Abid.\n')
})

// app.use('', (req,res,next) => {
//   if (req.headers.authorization) {
//     next();
//   }
//   else {
//     res.sendStatus(403);
//   }
// })

app.use('/holiday_api', createProxyMiddleware({
  target: API_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: {
    [`^/holiday_api`]: '',
  },
}))


app.listen(PORT, HOST, () => {
  console.log(`Starting Proxy at ${HOST}:${PORT}`)
})
