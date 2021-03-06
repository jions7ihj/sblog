{-# LANGUAGE OverloadedStrings #-}
module Handlers.Admin.Articles.Index(
  indexR
)where

import Data.Default
import Data.Int
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import qualified Data.Map as M

import Network.HTTP.Types.Status

import App.Types
import App.Context
import Utils.URI.String

import Handlers.Actions.Types
import Handlers.Actions.Common
import Handlers.Common

import qualified Models.DB as DB
import Utils.BlazeExtra.Pagination as Pagination

import qualified Views.Admin.Article as VAA

data ArticleIndex = ArticleIndex {
  page :: Integer
  ,count :: Integer
}


instance FormParams ArticleIndex where
  fromParams m = ArticleIndex <$>
    lookupInt "_page" 1 m <*>
    lookupInt "_count" 10 m

indexProcessor :: Processor ArticleIndex LT.Text
indexProcessor req = do
    a <- DB.runDBTry $ DB.fetchAllArticles p c
    total <- DB.runDBTry $ DB.fetchAllArticlesCount
    let pn = def {
      pnCurrentPage = (page req)
      ,pnTotal = (toInteger total)
      ,pnPerPage = (count req)
      ,pnMenuClass = "ui right floated pagination menu"
    }
    return $ (status200, ( VAA.renderIndex a base pn))
  where
    p = fromInteger $ page req
    c = fromInteger $ count req
    base = (toURI "/admin/articles")

authUser user req =
  if  user == "admin"
    then indexProcessor req
    else return $ (status302,"/admin/login")

indexR :: Response LT.Text
indexR = do
  view $ withParams $ withAuthorization authUser
