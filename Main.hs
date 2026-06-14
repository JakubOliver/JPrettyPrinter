module Main where

import Tree
import Utils

-- :set -isrc

main :: IO ()
main = do 
    content <- readFile "inputs/input1.java"
    let normalForm = toNormalForm content
    putStrLn normalForm

    let treeForm = intoTree normalForm
    print treeForm

    let config = Config {
        indentation = 4
    }

    let stringForm = fromTree (head treeForm) config
    putStrLn stringForm