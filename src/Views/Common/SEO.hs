{-# LANGUAGE OverloadedStrings #-}

module Views.Common.SEO where

import Control.Monad
import qualified Data.Text as T
import Data.Text.Lazy(Text)
import Data.String (fromString)
import qualified Text.Printf as PF

import Network.URI
import Text.Blaze.Html5((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A

import qualified Utils.BlazeExtra.Attributes as EA
import Utils.URI.String

import qualified Models.DB.Schema as M

metaProperty p v =
    H.meta ! property p ! A.content v
  where
    property = H.customAttribute "property"

metaName n v = H.meta ! A.name n ! A.content v

showTags :: [M.Tag] -> String
showTags tags =
    if length tags == 0
      then ""
      else foldr1 (\w s -> w ++ ',':s) ts
  where
    ts = map (\tag -> (M.tagName tag)) tags

keywordsAndDescription keywords description = do
  metaName "keywords" $ H.toValue keywords
  metaName "description" $ H.toValue description

openGraph :: String -> String -> String -> H.Html
openGraph title url description = do
  metaProperty "og:type" "website"
  metaProperty "og:title" $ H.toValue title
  metaProperty "og:url" $ H.toValue url
  metaProperty "og:description" $ H.toValue description

gaEvent :: String-> String ->H.Attribute
gaEvent ev ct =
  let
    v = (PF.printf "ga('send', 'event', '%s', '%s');" ev ct) :: String
  in
    A.onclick $ H.toValue v
