module Tree where

import Data.List

import Utils

data Tree a = Node a [Tree a] | Nil deriving Show

getBlocks :: String -> [(String,String)]
getBlocks "" = []
getBlocks input = (header,block): getBlocks rest
    where
        (header, block, rest) = getBlock input

getBlock :: String -> (String, String, String)
getBlock input = getBlock' input 0

getBlock' :: String -> Int -> (String, String, String)
getBlock' "" _ = ("", "", "")
getBlock' input@(i:is) depth
    | isOpeningBorder i && depth == 0 = getBlock' is (depth + 1)
    | isClosingBorder i && depth == 1 = ("", "", is)
    | depth == 0 = updateHeader i $ getBlock' is depth
    | isOpeningBorder i = updateBlock i $ getBlock' is (depth + 1)
    | isClosingBorder i = updateBlock i $ getBlock' is (depth - 1)
    | otherwise = updateBlock i $ getBlock' is depth
    where
        updateBlock :: Char -> (String, String, String) -> (String, String, String)
        updateBlock c (header, block, rest) = (header, c:block, rest)

        updateHeader :: Char -> (String, String, String) -> (String, String, String)
        updateHeader c (header, block, rest) = (c:header, block, rest)

splitOnEnhanced :: Char -> String -> [String]
splitOnEnhanced d s
    | isInfixOf "for" s = splitOnEnhanced' d s
    | otherwise = Utils.splitOn d s

splitOnEnhanced' :: Char -> String -> [String]
splitOnEnhanced' _ "" = []
splitOnEnhanced' _ [x] = [[x]]
splitOnEnhanced' d (i:is)
    | startsWith (i:is) "for" = [i:is]
    | d == i = [i]: splitOnEnhanced' d is
    | otherwise = (i:s):ss
        where
            (s:ss) = splitOnEnhanced' d is

intoTree :: String -> [Tree String]
intoTree "" = []
intoTree input = withoutBlock ++ Node header kids : intoTree rest
    where
        (headers, block, rest) = getBlock input 
        kids = intoTree block
        (header:parts) = reverse $ map strip $ splitOnEnhanced ';' headers
        withoutBlock = map (\x -> Node x []) $ reverse parts

toStripForm :: String -> String
toStripForm [] = []
toStripForm [x] = [x]
toStripForm input@(x:y:xs)
    | x == ' ' && y == ' ' = toStripForm (x:xs)
    | isBlockBorder x && y == ' ' = toStripForm (x:xs)
    | x == ' ' && isBlockBorder y = toStripForm (y:xs)
    | otherwise = x : toStripForm (y:xs)

toNormalForm :: String -> String
toNormalForm [] = []
toNormalForm input@(x:xs) = toStripForm $ map transForm input

transForm :: Char -> Char
transForm '\n' = ' '
transForm '\t' = ' '
transForm c = c

addIndentation :: Int -> String
addIndentation n = concat $ take n $ repeat " "

fromTree :: [Tree String] -> Config -> String
fromTree [] _ = ""
fromTree (tree:rest) config = fromTree' tree config 0 ++ fromTree rest config

fromTree' :: Tree String -> Config -> Int -> String
fromTree' (Node head child)  config depth = offset ++ toIndent ++ head ++ childText 
    where
        offset = if null child then "" else "\n"
        childText = if null child then "\n" else " {\n" ++ (concat $ map (\c -> fromTree' c config (depth + 1)) child) ++ toIndent ++ "}\n"
        toIndent = addIndentation $ depth * (indentation config)