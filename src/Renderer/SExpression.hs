{-# LANGUAGE RankNTypes, ScopedTypeVariables, OverloadedStrings #-}
module Renderer.SExpression
( renderSExpressionDiff
, renderSExpressionTerm
) where

import Data.Bifunctor.Join
import Data.ByteString hiding (foldr, spanEnd)
import Data.Record
import Prologue hiding (replicate, encodeUtf8)
import Diff
import Patch
import Info
import Term

-- | Returns a ByteString SExpression formatted diff.
renderSExpressionDiff :: (HasField fields Category, Foldable f) => Diff f (Record fields) -> ByteString
renderSExpressionDiff diff = printDiff diff 0 <> "\n"

-- | Returns a ByteString SExpression formatted term.
renderSExpressionTerm :: (HasField fields Category, Foldable f) => Term f (Record fields) -> ByteString
renderSExpressionTerm term = printTerm term 0 <> "\n"

printDiff :: (HasField fields Category, Foldable f) => Diff f (Record fields) -> Int -> ByteString
printDiff diff level = case runFree diff of
  Pure patch -> case patch of
    Insert term -> pad (level - 1) <> "{+" <> printTerm term level <> "+}"
    Delete term -> pad (level - 1) <> "{-" <> printTerm term level <> "-}"
    Replace a b -> pad (level - 1) <> "{ " <> printTerm a level <> pad (level - 1) <> "->" <> printTerm b level <> " }"
  Free (Join (_, annotation) :< syntax) -> pad' level <> "(" <> showAnnotation annotation <> foldr (\d acc -> printDiff d (level + 1) <> acc) "" syntax <> ")"
  where
    pad' :: Int -> ByteString
    pad' n = if n < 1 then "" else pad n
    pad :: Int -> ByteString
    pad n | n < 0 = ""
          | n < 1 = "\n"
          | otherwise = "\n" <> replicate (2 * n) space

printTerm :: (HasField fields Category, Foldable f) => Term f (Record fields) -> Int -> ByteString
printTerm term level = go term level 0
  where
    pad :: Int -> Int -> ByteString
    pad p n | n < 1 = ""
            | otherwise = "\n" <> replicate (2 * (p + n)) space
    go :: (HasField fields Category, Foldable f) => Term f (Record fields) -> Int -> Int -> ByteString
    go term parentLevel level = case runCofree term of
      (annotation :< syntax) -> pad parentLevel level <> "(" <> showAnnotation annotation <> foldr (\t acc -> go t parentLevel (level + 1) <> acc) "" syntax <> ")"

showAnnotation :: HasField fields Category => Record fields -> ByteString
showAnnotation = toS . category

space :: Word8
space = fromIntegral $ ord ' '
