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

untilStartOfBlock :: String -> (String, String)
untilStartOfBlock [] = ([], [])
untilStartOfBlock input@(i:is) 
    | isBlockBorder i = ([], (i:is))
    | otherwise = 
        let (before, after) = untilStartOfBlock is
        in (i:before, after)

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

data Tree a = Node a [Tree a] | Nil deriving Show

intoTree :: String -> [Tree String]
intoTree "" = []
intoTree input = Node header kids : intoTree rest
    where
        (header, block, rest) = getBlock input 
        kids = intoTree block

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

main :: IO ()
main = do 
    content <- readFile "inputs/input1.java"
    let normalForm = toNormalForm content
    putStrLn normalForm

    let treeForm = intoTree normalForm
    print treeForm