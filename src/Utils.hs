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

-- detects when the are same "for" and "for"
-- or is standalone prefix "for(int i = 0; i < 10; i++)" and "for"
-- but "fortune" is not standalone prefix for "for" therefore is false
startsWith :: String -> String -> Bool
startsWith [] [] = True
startsWith (s:ss) [] 
    | s == '(' || s == ' ' = True
    | otherwise = False
startsWith [] _ = False
startsWith (s:ss) (p:ps) = s == p && startsWith ss ps

-- TODO: vyresit parsovani for(int i = 0; i < 10; i++)
splitOn :: Char -> String -> [String]
splitOn _ "" = []
splitOn _ [x] = [[x]]
splitOn d (i:is)
    | d == i = [i]: splitOn d is
    | otherwise = (i:s):ss
        where
            (s:ss) = splitOn d is

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
    indentation :: Int,
    overwrite :: Bool
}

processArgs :: [String] -> Config
processArgs args = do
    let ind = 
            case getIndentation args of 
                Nothing -> defaultIndentation
                Just x -> x

    Config {
        filePath = getFilePath args,
        indentation = ind,
        overwrite = getOverwrite args
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

defaultOverwrite :: Bool
defaultOverwrite = False
--defaultOverwrite = True

getOverwrite :: [String] -> Bool
getOverwrite [] = defaultOverwrite
getOverwrite (i:is) = i == "-o" || i == "--overwrite" || getOverwrite is