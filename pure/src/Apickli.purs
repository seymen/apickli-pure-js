module Pure
  ( requestContext
  , Contextual
  , setUri
  , get
  )
  where

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

type Context =
  { templateChar :: Char
  , baseUri      :: A.URL
  }

defaultContext :: Context
defaultContext = { templateChar: '`', baseUri: "" }

newtype Contextual a b = Contextual { ctx :: a, data :: b }

{-- instance showContextual :: (Show a, Show b) => Show (Contextual a b) where --}
{--   show (Contextual a b) = "Contextual " <> (show a) <> " " (show b) --}

derive instance functorContextual :: Functor (Contextual a)

{-- instance functorContextual :: Functor Contextual where --}
  {-- map f (Contextual o) = Contextual { ctx: o.ctx, data1: (f o) } --}
  {-- map f (Contextual o) = Contextual $ o { data1 = (f o.data1) } --}

type Request = A.Request Unit
type Response = A.Response Unit
type RequestContext = Contextual Context Request

requestContext :: Context -> Request -> RequestContext
requestContext ctx req = Contextual { ctx: mergedCtx, data: mergedReq }
  where mergedCtx = Record.merge ctx defaultContext
        mergedReq = Record.merge req A.defaultRequest

setUri :: A.URL -> RequestContext -> RequestContext
setUri uri = map (\req -> req { url = "boo" })

foo :: Request -> Request
foo req = req { url = "boo" }

get' :: RequestContext -> Effect (Promise Response)
get' (Contextual c) = fromAff $ do
  result <- A.request $ c.data
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 RequestContext (Promise Response)
get = mkEffectFn1 get'

exclaim :: String -> String
exclaim s = s <> "!"
