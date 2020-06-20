module Apickli
  ( makeRequestContext
  , ContextWith
  , setUri
  , setHeader
  , get
  )
  where

import Prelude

import Affjax as A
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat (json)
import Data.Argonaut.Core (Json)
import Data.Either (Either(..))
import Control.Promise (Promise, fromAff)
import Control.Extend (class Extend, extend)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Record as Record
import Effect.Aff (throwError)
import Data.Array ((:))

type Context =
  { templateChar :: Char
  , baseUri      :: A.URL
  }

defaultContext :: Context
defaultContext = { templateChar: '`', baseUri: "" }

newtype ContextWith a = ContextWith
  { context :: Context
  , data :: a
  , map :: (a -> a) -> ContextWith a
  , extend :: (ContextWith a -> a) -> ContextWith a
  }

instance functorContextWith :: Functor (ContextWith) where
  map f (ContextWith a) = makeContextWith a.context (f a.data)

instance showContextWith :: (Show a) => Show (ContextWith a) where
  show (ContextWith a) =
    "ContextWith (" <> show a.context <> "," <> show a.data <> ")"

instance extendContextWith :: Extend (ContextWith) where
  extend f c@(ContextWith a) = makeContextWith a.context $ f c

type Request = A.Request Json
type Response = A.Response Json
type RequestContext = ContextWith Request

defaultRequest :: A.Request Json
defaultRequest  = A.defaultRequest { responseFormat= json }

makeContextWith :: forall a. Context -> a -> ContextWith a
makeContextWith c x = ContextWith
  {
    context: c
  , data: x
  , map: (\f -> f <$> makeContextWith c x)
  , extend: (\f -> extend f $ makeContextWith c x)
  }

makeRequestContext :: Context -> Request -> RequestContext
makeRequestContext c r = makeContextWith mergedCtx mergedReq
  where mergedCtx = Record.merge c defaultContext
        mergedReq = Record.merge r defaultRequest

setUri :: A.URL -> RequestContext -> Request
setUri url (ContextWith o) = o.data { url = url }

setHeader :: String -> String -> RequestContext -> Request
setHeader name value (ContextWith o) =
  o.data { headers = (RequestHeader name value) : o.data.headers }

get' :: RequestContext -> Effect (Promise Response)
get' (ContextWith o) = fromAff $ do
  result <- A.request o.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
