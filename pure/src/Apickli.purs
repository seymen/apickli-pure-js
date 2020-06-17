module Apickli
  ( requestContext
  , ContextWith
  , RequestContextWrapper
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
import Effect.Aff

type Context =
  { templateChar :: Char
  , baseUri      :: A.URL
  }

defaultContext :: Context
defaultContext = { templateChar: '`', baseUri: "" }

newtype ContextWith a = ContextWith { context :: Context, data :: a }

instance showContextWith :: (Show a) => Show (ContextWith a) where
  show (ContextWith a) = "ContextWith " <> (show a)

instance functorContextWith :: Functor ContextWith where
  map f (ContextWith a) = ContextWith $ a { data = f a.data }

instance extendContextWith :: Extend (ContextWith) where
  extend f c@(ContextWith a) = ContextWith $ a { data = (f c) }

type Request = A.Request Unit
type Response = A.Response Unit
type RequestContext = ContextWith Request

newtype RequestContextWrapper = RequestContextWrapper
  {
    context :: Context
  , data :: Request
  , map :: (Request -> Request) -> RequestContextWrapper
  , extend :: (RequestContext -> Request) -> RequestContextWrapper
  }

wrapToJS :: RequestContext -> RequestContextWrapper
wrapToJS t@(ContextWith o) = RequestContextWrapper
  {
    context: o.context
  , data: o.data
  , map: (\f -> wrapToJS $ map f t)
  , extend: (\f -> wrapToJS $ extend f t)
  }

requestContext :: Context -> Request -> RequestContextWrapper
requestContext c r = wrapToJS $ ContextWith { context: mergedCtx, data: mergedReq }
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
