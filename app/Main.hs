{-# LANGUAGE OverloadedStrings #-}
module Main where

import Data.HashMap.Strict (fromList, HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.Hashable
import Data.Text
import System.Environment
import System.Exit (exitFailure)
import System.IO (IOMode(ReadMode), openFile, hGetContents)
import System.IO.Error (tryIOError)
import Text.Ginger
       (SourcePos, makeContextHtml, Template, toGVal, runGinger, parseGingerFile, VarName)
import Text.Ginger.GVal (ToGVal, GVal)
import Text.Ginger.Html (htmlSource)


-- Given a Template and a HashMap of context, render the template to Text
render :: Template SourcePos -> HashMap VarName [Int] -> Text
render template contextMap =
  let contextLookup = flip scopeLookup contextMap
      context = makeContextHtml contextLookup
  in htmlSource $ runGinger context template


-- Wrapper around HashMap.lookup that applies toGVal to the value found.
-- Any value referenced in a template, returned from within a template, or used
-- in a template context, will be a GVal
scopeLookup
  :: (Hashable k, Eq k, ToGVal m b)
  => k -> HashMap.HashMap k b -> GVal m
scopeLookup key context = toGVal $ HashMap.lookup key context


loadFileMay :: FilePath -> IO (Maybe String)
loadFileMay fn =
  tryIOError (loadFile fn) >>= \x -> case x of
      Right contents -> return (Just contents)
      Left _ -> return Nothing

  where
    loadFile :: FilePath -> IO String
    loadFile fn' = openFile fn' ReadMode >>= hGetContents


-- Assuming there's an html file called "base.html" in the current directory and
-- that html file's contents are `Hi, {{ name }}`, attempt to parse "base.html"
-- and print the rendered template
main :: IO ()
main = do
  templateFile:n:_ <- getArgs
  let context = fromList [("xs", Prelude.replicate (read n) 0)] :: HashMap Text [Int]
  template <- parseGingerFile loadFileMay templateFile
  case template of
    Left err -> print err >> exitFailure
    Right template' -> putStrLn . unpack $ render template' context
