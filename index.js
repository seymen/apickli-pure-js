const { get, requestContext, setUri } = require('./pure/dist/apickli')

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

const boo = reqCtx => {
  console.log(reqCtx)
  reqCtx.data.url += "?a=a"
  return reqCtx.data
}

// Promise.resolve(requestContext(ctx)(req))
// .then(debug)
// .then(setUri("!"))
// .then(debug)
// .then(get)
// .then(debug)

const p = requestContext(ctx)(req)
  .extend(setUri('https://httpbin.org/get'))
  .extend(boo)
  .map(debug)
  // .extend(get)

