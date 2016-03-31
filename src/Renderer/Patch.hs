import Info
patch diff blobs = case getLast $ foldMap (Last . Just) string of
  Just c | c /= '\n' -> string ++ "\n\\ No newline at end of file\n"
  _ -> string
  where string = header blobs ++ mconcat (showHunk blobs <$> hunks diff blobs)
showHunk blobs hunk = maybeOffsetHeader ++
  concat (showChange sources <$> changes hunk) ++
  showLines (snd sources) ' ' (snd <$> trailingContext hunk)
        maybeOffsetHeader = if lengthA > 0 && lengthB > 0
                            then offsetHeader
                            else mempty
        offsetHeader = "@@ -" ++ offsetA ++ "," ++ show lengthA ++ " +" ++ offsetB ++ "," ++ show lengthB ++ " @@" ++ "\n"
        (lengthA, lengthB) = runBoth . fmap getSum $ hunkLength hunk
        (offsetA, offsetB) = runBoth . fmap (show . getSum) $ offset hunk
header :: Both SourceBlob -> String
header blobs = intercalate "\n" [filepathHeader, fileModeHeader, beforeFilepath, afterFilepath] ++ "\n"
          (Just mode, Nothing) -> intercalate "\n" [ "deleted file mode " ++ modeToDigits mode, blobOidHeader ]
            "old mode " ++ modeToDigits mode1,
            "new mode " ++ modeToDigits mode2,
            blobOidHeader
hunks _ blobs | sources <- source <$> blobs
              , sourcesEqual <- runBothWith (==) sources
              , sourcesNull <- runBothWith (&&) (null <$> sources)
              , sourcesEqual || sourcesNull
  = [Hunk { offset = mempty, changes = [], trailingContext = [] }]