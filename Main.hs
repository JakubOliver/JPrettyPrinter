module Main where

import System.Environment

import Tree
import Utils

-- :set -isrc
-- :set args -f input/input1.java

processFile :: FilePath -> Config -> IO()
processFile filepath  config = do
    content <- readFile filepath

    let stringForm = fromTree (intoTree $ toNormalForm content) config

    putStrLn stringForm

    -- writeFile filepath stringForm
    if overwrite config 
        then writeFile filepath stringForm 
        else writeFile ("outputs/" ++ last (splitOn '/' filepath)) stringForm

    return ()

processFiles :: [FilePath] -> Config -> IO()
processFiles [] _ = do return ()
processFiles (f:fs) config = do
    processFile f config 
    processFiles fs config

main :: IO ()
main = do 
    args <- getArgs

    let config = processArgs args

    files <- getJavaFiles $ filePath config

    processFiles files config