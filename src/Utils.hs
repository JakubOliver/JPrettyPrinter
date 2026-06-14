module Utils where

import System.Directory
import Control.Monad (filterM)
import System.FilePath

getJavaFiles :: FilePath -> IO [FilePath]
getJavaFiles path = do
    content <- listDirectory path
    dirs <- filterM doesDirectoryExist $ map (path </>) content
    files <- filterM doesFileExist $ filter (\x -> takeExtension x == ".java") $ map (path </>) content

    innerFiles <-  mapM getJavaFiles dirs

    return (files ++ concat innerFiles)

strip :: String -> String
strip s = stripFront $ reverse $ stripFront $ reverse s

stripFront :: String -> String
stripFront "" = ""
stripFront (s:ss) 
    | s == ' ' = stripFront ss
    | otherwise = (s:ss)

isBlockBorder :: Char -> Bool
isBlockBorder '{' = True
isBlockBorder '}' = True
isBlockBorder _ = False

isOpeningBorder :: Char -> Bool
isOpeningBorder '{' = True
isOpeningBorder _ = False

isClosingBorder :: Char -> Bool
isClosingBorder '}' = True
isClosingBorder _ = False

data Config = Config {
    filePath :: String,
    indentation :: Int
}

processArgs :: [String] -> Config
processArgs args = do
    let filepath = getFilePath args
    let ind = 
            case getIndentation args of 
                Nothing -> defaultIndentation
                Just x -> x

    Config {
        filePath = filepath,
        indentation = ind
    }

defaultIndentation :: Int
defaultIndentation = 4

filePathError :: String
filePathError = "No input filepath provided!!!"

getFilePath :: [String] -> String
getFilePath [] = error filePathError
getFilePath [x] = error filePathError
getFilePath args@(x:y:rest) 
    | x == "-f" || x == "--file" = y
    | otherwise = getFilePath (y:rest)

getIndentation :: [String] -> Maybe Int
getIndentation [] = Nothing
getIndentation [x] = Nothing
getIndentation args@(x:y:rest)
    | x == "-i" || x == "--indetation" = Just (read y :: Int)
    | otherwise = getIndentation (y:rest)