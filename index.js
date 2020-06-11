const { get, eitherP } = require('./pure/dist/pure')

const a =
  get("https://1httpbin.org/get")
  .then(
    a => console.log('then --> ', a),
    a => console.log('catch -->', a)
  )

