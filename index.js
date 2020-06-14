const { requestContext, setUri } = require('./pure/dist/pure')

const req = {
  url: 'https://httpbin.org/get'
}

// const reqCtx = requestContext({})(req)

// const a =
//   get(reqCtx)
//   .then(
//     a => console.log('then --> ', a),
//     a => console.log('catch -->', a)
//   )

const inc = a => a + 1

Promise.resolve(requestContext({})(req))
.then(setUri("!"))
.then(console.log)

// console.log(reqCtx2.data)

