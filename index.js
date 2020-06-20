const { get, makeRequestContext, setUri, setHeader } = require('./pure/dist/apickli')

const ctx = {
  baseUri: 'https://httpbin.org/get'
}

const req = {
  url: '/get'
}

const debug = s => {
  console.log(s)
  return s
}

const extend = reqCtx => {
  reqCtx.data.url += "?a=a"
  return reqCtx.data
}

const requestContext = makeRequestContext(ctx)(req)
  .extend(setUri('https://httpbin.org/get'))
  .extend(extend)
  .extend(setHeader("damla")("ozan"))
  .map(debug)

requestContext.extend(get).data
  .then(console.log, console.log)
