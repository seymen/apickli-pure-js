module Apickli
  ( requestContext
  , Contextual
  , setUri
  , get
  )
  where

import Prelude

import Affjax as A
import Data.Either (Either(..))
import Control.Promise (Promise, fromAff)
import Control.Extend (class Extend, extend)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Control.Monad.Except (throwError)
import Record as Record

type Context =
  { templateChar :: Char
  , baseUri      :: A.URL
  }

defaultContext :: Context
defaultContext = { templateChar: '`', baseUri: "" }

newtype Contextual a = Contextual { ctx :: Context, data :: a }

instance showContextual :: (Show a) => Show (Contextual a) where
  show (Contextual a) = "Contextual " <> (show a)

derive instance functorContextual :: Functor (Contextual)

instance extendContextual :: Extend (Contextual) where
  extend f c@(Contextual a) = Contextual $ a { data = (f c) }

type Request = A.Request Unit
type Response = A.Response Unit
type RequestContext = Contextual Request

requestContext :: Context -> Request -> RequestContext
requestContext ctx req = Contextual { ctx: mergedCtx, data: mergedReq }
  where mergedCtx = Record.merge ctx defaultContext
        mergedReq = Record.merge req A.defaultRequest

setUri :: A.URL -> RequestContext -> RequestContext
setUri uri = extend (\(Contextual c) -> c.data { url = c.ctx.baseUri })

get' :: RequestContext -> Effect (Promise Response)
get' (Contextual c) = fromAff $ do
  result <- A.request $ c.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
