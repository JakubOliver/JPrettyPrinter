module Main where

import System.Environment

import Tree
import Utils

-- :set -isrc
-- :set args -f input/input1.java

--TODO: check whether all flags are valid
processFile :: FilePath -> Config -> IO()
processFile filepath  config = do
    content <- readFile filepath

    let stringForm = fromTree (intoTree $ toNormalForm content) config

    --putStrLn stringForm

    if overwrite config 
        then writeFile filepath stringForm 
        else writeFile ("outputs/" ++ head (splitOn '.' (last (splitOn '/' filepath))) ++ "debug.java") stringForm

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

    if help config 
        then 
            putStrLn getHelpText 
        else do
            files <- getJavaFiles $ filePath config
            processFiles files config