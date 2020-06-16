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

type Context =
  { templateChar :: Char
  , baseUri      :: A.URL
  }

defaultContext :: Context
defaultContext = { templateChar: '`', baseUri: "" }

newtype ContextWith a = ContextWith { ctx :: Context, data :: a }

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
  { requestContext :: RequestContext
  , map :: (Request -> Request) -> RequestContextWrapper
  , extend :: (RequestContext -> Request) -> RequestContextWrapper
  }

wrapToJS :: RequestContext -> RequestContextWrapper
wrapToJS t@(ContextWith o) = RequestContextWrapper
  { requestContext: t
  , map: (\f -> wrapToJS $ map f t)
  , extend: (\f -> wrapToJS $ extend f t)
  }

requestContext :: Context -> Request -> RequestContextWrapper
requestContext ctx req = wrapToJS $ ContextWith { ctx: mergedCtx, data: mergedReq }
  where mergedCtx = Record.merge ctx defaultContext
        mergedReq = Record.merge req A.defaultRequest

setUri :: A.URL -> RequestContext -> Request
setUri url (ContextWith o) = o.data { url = url }

get' :: RequestContext -> Effect (Promise Response)
get' (ContextWith req) = fromAff $ do
  result <- A.request $ req.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
