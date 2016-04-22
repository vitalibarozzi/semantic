  Hunk(..),
  truncatePatch
import Data.Text (pack, Text)

-- | Render a timed out file as a truncated diff.
truncatePatch :: DiffArguments -> Both SourceBlob -> Text
truncatePatch _ blobs = pack $ header blobs ++ "#timed_out\nTruncating diff: timeout reached.\n"
patch :: Renderer a
patch diff blobs = pack $ case getLast (foldMap (Last . Just) string) of
getRange (Free (Annotated (Info range _ _) _)) = range
getRange (Pure patch) = let Info range _ _ :< _ = getSplitTerm patch in range
-- | A hunk representing no changes.
emptyHunk :: Hunk (SplitDiff a Info)
emptyHunk = Hunk { offset = mempty, changes = [], trailingContext = [] }

hunks :: Diff a Info -> Both SourceBlob -> [Hunk (SplitDiff a Info)]
  = [emptyHunk]