module Apickli
  ( makeRequestContext
  , ContextWith
  , setUri
  , get
  )
  where

import Prelude

import Affjax as A
import Data.Either (Either(..))
import Control.Promise (Promise, fromAff)
import Control.Extend (class Extend)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Record as Record
import Effect.Aff (throwError)

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

type Request = A.Request Unit
type Response = A.Response Unit
type RequestContext = ContextWith Request

makeContextWith :: forall a. Context -> a -> ContextWith a
makeContextWith c x = ContextWith
  {
    context: c
  , data: x
  , map: (\f -> makeContextWith c (f x))
  , extend: (\f -> makeContextWith c $ f (makeContextWith c x))
  }

makeRequestContext :: Context -> Request -> RequestContext
makeRequestContext c r = makeContextWith mergedCtx mergedReq
  where mergedCtx = Record.merge c defaultContext
        mergedReq = Record.merge r A.defaultRequest

setUri :: A.URL -> RequestContext -> Request
setUri url (ContextWith o) = o.data { url = url }

get' :: RequestContext -> Effect (Promise Response)
get' (ContextWith o) = fromAff $ do
  result <- A.request o.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
