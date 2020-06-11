module Pure
  ( get
  ) where

import Prelude

import Affjax as A
import Affjax.ResponseFormat (json)
import Data.Either (Either(..))
import Data.Argonaut.Core (Json)
import Control.Promise (Promise, fromAff)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception (error)
import Control.Monad.Except (throwError)

type HttpResponse = Either A.Error (A.Response Json)
type JsonResponse = A.Response Json

get' :: String -> Effect (Promise JsonResponse)
get' url = fromAff $ do
  result <- A.get json url
  case result of
    Left err -> throwError $ error $ A.printError err
    Right res -> pure res

get :: EffectFn1 String (Promise JsonResponse)
get = mkEffectFn1 get'
