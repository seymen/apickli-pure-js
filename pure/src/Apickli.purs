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

{-- derive instance functorContextWith :: Functor (ContextWith) --}
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
  }

wrapToJS :: RequestContext -> RequestContextWrapper
wrapToJS reqCtx = RequestContextWrapper
  { requestContext: reqCtx
  , map: (\f -> wrapToJS $ map f reqCtx)
  }

requestContext :: Context -> Request -> RequestContextWrapper
requestContext ctx req = wrapToJS $ ContextWith { ctx: mergedCtx, data: mergedReq }
  where mergedCtx = Record.merge ctx defaultContext
        mergedReq = Record.merge req A.defaultRequest

setUri :: A.URL -> Request -> Request
setUri url r = r { url = url }

{-- setUri :: A.URL -> RequestContext -> RequestContext --}
{-- setUri uri = extend (\(ContextWith c) -> c.data { url = c.ctx.baseUri }) --}

get' :: RequestContext -> Effect (Promise Response)
get' (ContextWith c) = fromAff $ do
  result <- A.request $ c.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'
