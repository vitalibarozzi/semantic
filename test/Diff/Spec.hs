{-# LANGUAGE DataKinds #-}
module Diff.Spec where

import Category
import Data.Record
import Data.Record.Arbitrary ()
import Data.Text.Arbitrary ()
import Diff
import Diff.Arbitrary
import Interpreter
import Prologue
import Term.Arbitrary
import Test.Hspec
import Test.Hspec.QuickCheck
import Test.QuickCheck

spec :: Spec
spec = parallel $ do
  prop "equality is reflexive" $
    \ a b -> let diff = diffTerms (free . Free) (==) diffCost (toTerm a) (toTerm (b :: ArbitraryTerm Text (Record '[Category]))) in
      diff `shouldBe` diff

  prop "equal terms produce identity diffs" $
    \ a -> let term = toTerm (a :: ArbitraryTerm Text (Record '[Category])) in
      diffCost (diffTerms (free . Free) (==) diffCost term term) `shouldBe` 0

  describe "beforeTerm" $ do
    prop "recovers the before term" $
      \ a b -> let diff = diffTerms (free . Free) (==) diffCost (toTerm a) (toTerm (b :: ArbitraryTerm Text (Record '[Category]))) in
        beforeTerm diff `shouldBe` Just (toTerm a)

  describe "ArbitraryDiff" $ do
    prop "generates diffs of a specific size" . forAll ((arbitrary >>= \ n -> (,) n <$> diffOfSize n) `suchThat` ((> 0) . fst)) $
      \ (n, diff) -> arbitraryDiffSize (diff :: ArbitraryDiff Text ()) `shouldBe` n
