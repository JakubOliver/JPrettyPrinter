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