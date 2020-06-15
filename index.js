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

// Promise.resolve(requestContext(ctx)(req))
// .then(debug)
// .then(setUri("!"))
// .then(debug)
// .then(get)
// .then(debug)

console.log(
  requestContext(ctx)(req)
  .map(r => { r.url = 'doo'; return r })
  .map(setUri('fgfgdf'))
)
