module Pure
  ( get
  , eitherP
  ) where

import Prelude

import Affjax as A
import Affjax.ResponseFormat (json)
import Data.Either (Either, either)
import Effect.Aff (Aff)
import Data.Argonaut.Core (Json, stringify)
import Control.Promise (Promise, fromAff)
import Effect (Effect)
import Effect.Aff.Compat (mkEffectFn1)
import Effect.Uncurried (EffectFn1)
import Effect.Exception

eitherP :: forall a b c. (a -> c) -> (b -> c) -> Either a b -> c
eitherP = either

type HttpResponse = Either A.Error (A.Response Json)

get'' :: String -> Effect (Promise HttpResponse)
get'' url = fromAff $ A.get json url

get :: EffectFn1 String (Promise HttpResponse)
get = mkEffectFn1 get''

{-- get' :: String -> Aff String --}
{-- get' url = do --}
{--   result <- A.get json url --}
{--   case result of --}
{--     Left err   -> pure $ A.printError err --}
{--     Right response -> pure $ stringify response.body --}

{-- get'' :: String -> Effect (Promise String) --}
{-- get'' url = fromAff $ get' url --}

{-- get :: EffectFn1 String (Promise String) --}
{-- get = mkEffectFn1 get'' --}

