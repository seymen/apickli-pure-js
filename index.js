const { get, requestContext } = require('./pure/dist/pure')

const req = {
  url: 'https://httpbin.org/get'
}

const reqCtx = requestContext({})(req)

const a =
  get(reqCtx)
  .then(
    a => console.log('then --> ', a),
    a => console.log('catch -->', a)
  )

