module Main where

import System.Environment

import Tree
import Utils

-- :set -isrc
-- :set args -f input/input1.java

modifyContent :: String -> String
modifyContent s = "{\n" ++ s ++ "\n}"

processFile :: FilePath -> Config -> IO()
processFile filepath  config = do
    content <- readFile filepath

    let stringForm = fromTree (head $ intoTree $ toNormalForm content) config

    putStrLn stringForm

    return ()

main :: IO ()
main = do 
    args <- getArgs

    let config = processArgs args

    processFile (filePath config) config