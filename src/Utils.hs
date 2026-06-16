module Utils where

import System.Directory
import Control.Monad (filterM, when)
import System.FilePath

-- If input filepath points to java file returns itself
-- If points to directory then return array of all java files 
-- in the directory and subdirectories
getJavaFiles :: FilePath -> IO [FilePath]
getJavaFiles path = do
    isFile <- doesFileExist path 

    if isFile 
        then 
            return [path]
        else do
            content <- listDirectory path
            dirs <- filterM doesDirectoryExist $ map (path </>) content
            files <- filterM doesFileExist $ 
                filter (\x -> takeExtension x == ".java") $ 
                map (path </>) content

            innerFiles <-  mapM getJavaFiles dirs

            return (files ++ concat innerFiles)

-- Removes whitespaces around text
strip :: String -> String
strip s = stripFront $ reverse $ stripFront $ reverse s

stripFront :: String -> String
stripFront "" = ""
stripFront (s:ss) 
    | s == ' ' = stripFront ss
    | otherwise = s:ss

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
    overwrite :: Bool,
    help :: Bool
}

--creates configuration based on arguments
processArgs :: [String] -> Config
processArgs args = do
    let areArgsValid = validateArgs args getValidOptions

    if not areArgsValid
    then error "Arguments are not valid!!!"
    else do 
        let ind = 
                case getIndentation args of 
                    Nothing -> defaultIndentation
                    Just x -> x

        Config {
            filePath = getFilePath args,
            indentation = ind,
            overwrite = getOverwrite args,
            help = getHelp args
        }

defaultIndentation :: Int
defaultIndentation = 4

filePathError :: String
filePathError = "No input filepath provided!!!"

validateArgs :: [String] -> [String] -> Bool
validateArgs [] _ = True
validateArgs (a:as) options 
    | isOption a = elem a options && validateArgs as options
    | otherwise = validateArgs as options

isOption :: String -> Bool
isOption "" = False
isOption (s:_) = s == '-'

getValidOptions :: [String]
getValidOptions = 
    ["-f", "--file", 
     "-i", "--indentation", 
     "-o", "--overwrite", 
     "-h", "--help"]

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
    | x == "-i" || x == "--indentation" = Just (read y :: Int)
    | otherwise = getIndentation (y:rest)

getBoolArgument :: [String] -> [String] -> Bool -> Bool
getBoolArgument [] _ defaultValue = defaultValue
getBoolArgument arguments@(i:is) possibleOptions defaultValue = 
    elem i possibleOptions || getBoolArgument is possibleOptions defaultValue

-- If you wish to have defaultly enabled overwrite mode 
-- then uncomment option with True and comment the other one

defaultOverwrite :: Bool
defaultOverwrite = False
--defaultOverwrite = True

getOverwrite :: [String] -> Bool
getOverwrite args = getBoolArgument args ["-o", "--overwrite"] defaultOverwrite

defaulHelp :: Bool
defaulHelp = False

getHelp :: [String] -> Bool
getHelp args = getBoolArgument args ["-h", "--help"] defaulHelp

getHelpText :: String
getHelpText = 
    "Arguments:\n" ++ 
        "\t-f, --file\t\tpath to the directory/target file\n" ++ 
        "\t-o, --overwrite\t\twhether the corrected files should overwrite the existing files\n" ++ 
        "\t-i, --indentation\tnumber of spaces to use for indentation\n" ++
        "\t-h, --help\t\tshows help menu"