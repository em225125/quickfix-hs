{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}

module AlphaHeavy.QuickFIX.SetMessageField where

import Data.ByteString (ByteString)
import Data.Int
import GHC.Generics
import Data.Time (UTCTime, formatTime)
import System.Locale (defaultTimeLocale)

import AlphaHeavy.FIX as FIX
import AlphaHeavy.QuickFIX.Foreign
import AlphaHeavy.QuickFIX.Types

class SetMessageField a where
  setMessageField :: QuickFIXMessagePtr -> Int -> a -> IO ()

instance SetMessageField Bool where
  setMessageField msg =
    setBoolField msg . fromIntegral

instance SetMessageField Char where
  setMessageField msg =
    setCharField msg . fromIntegral

instance SetMessageField Int where
  setMessageField msg fid =
    setIntField msg (fromIntegral fid) . fromIntegral

instance SetMessageField Int32 where
  setMessageField msg =
    setIntField msg . fromIntegral

instance SetMessageField Int64 where
  setMessageField msg fid =
    setIntField msg (fromIntegral fid) . fromIntegral

instance SetMessageField Float where
  setMessageField msg fid =
    setDoubleField msg (fromIntegral fid) . realToFrac

instance SetMessageField Double where
  setMessageField msg =
    setDoubleField msg . fromIntegral

instance SetMessageField String where
  setMessageField msg =
    setStringFieldWrapper msg . fromIntegral

instance SetMessageField ByteString where
  setMessageField = error "no bytestring support yet"

instance SetMessageField Data.Time.UTCTime where
  setMessageField msg fid val =
   let -- Not everyone seems to like milliseconds so we'll leave those out for now
        val' = formatTime defaultTimeLocale "%0Y%m%d-%H:%M:%S" val

    in setMessageField msg fid (val' :: String)

instance SetMessageField Decimal where
  setMessageField msg fid =
    setMessageField msg fid . show

instance SetMessageField Exchange where
  setMessageField msg fid ex =
    setMessageField msg fid $! case ex of
      Exchange_NASDAQ  -> "O"
      Exchange_NYSE    -> "N"
      Exchange_SMART   -> "SMART"
      Exchange_OTHER s -> s

instance SetMessageField (U1 x) where
  setMessageField _ _ _ =
    return ()
