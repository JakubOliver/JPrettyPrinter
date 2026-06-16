module Tree where

import Data.List

import Utils

data Tree a = Node a [Tree a] | Nil deriving Show

-- returns triplet (header, block, rest)
-- where header is header of block, 
-- block is content of inner block
-- and rest is all content after the inner block
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

-- splits text based on provided delimeter
-- it is different than normal splitOn, because it solves prolem with
-- parsing for block in Java, becase these are exception in Java and 
-- the semicolon does not mean "end of line" but in all valid
-- cases after for header have to come block, therefore if it 
-- encounter for key word, then stops processing and returns with 
-- unprocessed rest
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

-- processes Java code in normalForm into treeForm
-- treeForm has following properties:
-- value of the node denotes one line in final format
-- if line in question is header for some inner block
-- then the content of inner block is represented by chilren
-- of the node
intoTree :: String -> [Tree String]
intoTree s = intoTree' s True

-- note: the boolean argument denotes whether the header is 
-- equal to the whole text container in header and block
-- therefore distinguish header with empty block, which
-- have to be enclosed into brackets, and header without block
intoTree' :: String -> Bool -> [Tree String]
intoTree' "" True = []
intoTree' "" False = [Node "" []]
intoTree' input _  = withoutBlock ++ Node header kids : intoTree' rest True
    where
        (headers, block, rest) = getBlock input 
        kids = intoTree' block (headers == input)
        (header:parts) = reverse $ map strip $ splitOnEnhanced ';' headers
        withoutBlock = map (\x -> Node x []) $ reverse parts

-- strips text of necessary white spaces between code
-- elements and around semicolons and brackets
toStripForm :: String -> String
toStripForm [] = []
toStripForm [x]
    | x == ' ' = []
    | otherwise = [x]
toStripForm input@(x:y:xs)
    | x == ' ' && y == ' ' = toStripForm (x:xs)
    | (isBlockBorder x || x == '(') && y == ' ' = toStripForm (x:xs)
    | x == ' ' && (isBlockBorder y || y == ';' || y == ')') = toStripForm (y:xs)
    | otherwise = x : toStripForm (y:xs)

-- removes uncessary whitespaces, tabs and end of lines
toNormalForm :: String -> String
toNormalForm [] = []
toNormalForm input@(x:xs) = toStripForm $ map transForm input

transForm :: Char -> Char
transForm '\n' = ' '
transForm '\t' = ' '
transForm c = c

addIndentation :: Int -> String
addIndentation n = concat $ replicate n " "

-- converts code from tree form back into text form
fromTree :: [Tree String] -> Config -> String
fromTree [] _ = ""
fromTree (tree:rest) config = fromTree' tree config False 0 ++ fromTree rest config

fromTree' :: Tree String -> Config -> Bool -> Int -> String
fromTree' (Node head child) config firstChild depth = 
    offset ++ toIndent ++ head ++ childText 
    where
        isElse = isPrefixOf "else" head
        offset = if null child || firstChild || isElse then "" else "\n"

        childText = 
            if null child 
            then "\n" 
            else 
                let (first:others) = child

                in "{\n" ++ 
                fromTree' first config True (depth + 1) ++
                concatMap (\c -> fromTree' c config False (depth + 1)) others ++ 
                toIndent ++ 
                "}\n"

        toIndent = addIndentation $ depth * indentation config