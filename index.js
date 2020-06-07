const { get, eitherP } = require('./pure/dist/pure')
const { Either } = require('crocks')
const { Right, Left } = Either

const toEither = (x) =>
  new Promise((resolve, reject) =>
    eitherP
      (a => reject(a))
      (a => resolve(a))
      (x)
  )

const a = get("https://httpbin1.org/get")
  .then(toEither)
  .then(a => console.log('THEN:', a))
  .catch(a => console.log('CATCH:', a))
