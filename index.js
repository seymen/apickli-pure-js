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

Promise.resolve(requestContext(ctx)(req))
.then(setUri("!"))
.then(debug)
.then(get)
.then(debug)
