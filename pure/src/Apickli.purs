module Pure
  ( get
  , requestContext
  ) where

import Prelude

import Affjax as A
import Data.Either (Either(..))
import Data.Argonaut.Core (Json)
import Control.Promise (Promise, fromAff)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Control.Monad.Except (throwError)
import Record as Record
import Data.Tuple

type Request = A.Request Unit
type Response = A.Response Unit
type Context = { templateChar :: Char }
type RequestContext = Tuple Context Request

defaultContext :: Context
defaultContext = { templateChar: '`' }

requestContext :: Context -> Request -> RequestContext
requestContext ctx req = Tuple mergedCtx mergedReq
  where mergedCtx = Record.merge ctx defaultContext
        mergedReq = Record.merge req A.defaultRequest

get' :: RequestContext -> Effect (Promise Response)
get' reqCtx = fromAff $ do
  result <- A.request $ snd reqCtx
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
