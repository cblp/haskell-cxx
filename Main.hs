{-# OPTIONS -ddump-splices #-}

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

import           Control.Exception (mask_)
import           Control.Monad (unless)
import qualified Data.Map.Strict as Map
import           Data.Proxy (Proxy)
import           Data.Word (Word64)
import           Foreign (FinalizerPtr, ForeignPtr, finalizeForeignPtr,
                          newForeignPtr)
import           Language.C.Inline.Context (ctxTypesTable)
import qualified Language.C.Inline.Cpp as Cpp
import           Language.C.Types (TypeSpecifier (TypeName))
import           Language.Haskell.TH.Syntax (addDependentFile)

newtype Foo = Foo (ForeignPtr (Proxy Foo))

Cpp.context
    $   Cpp.cppCtx
    <>  Cpp.bsCtx
    <>  Cpp.fptrCtx
    <>  mempty
        { ctxTypesTable = Map.singleton (TypeName "Foo") [t| Proxy Foo |] }
Cpp.include "foo.hxx" <* addDependentFile "foo.hxx"
Cpp.include "<cstdlib>"

Cpp.include "<cmath>"

main :: IO ()
main = do
    x <- [Cpp.exp| double { cos(1) } |]
    print x
    runTest
    checkResults

runTest :: IO ()
runTest = do
    Foo foo <- newFoo
    finalizeForeignPtr foo

checkResults :: IO ()
checkResults = do
    events <- getEvents
    unless (events == allEvents) $
        fail $
            unwords ["EVENTS: expected", show allEvents, ", got", show events]

newFoo :: IO Foo
newFoo = Foo <$> newForeignFoo

newForeignFoo :: IO (ForeignPtr (Proxy Foo))
newForeignFoo = mask_ $ do
    p <- [Cpp.exp| Foo * { new Foo } |]
    newForeignPtr deleteFoo p

foreign import ccall "&deleteFoo" deleteFoo :: FinalizerPtr a

foreign import ccall "getEvents" getEvents :: IO Word64

foreign import ccall "allEvents" allEvents :: Word64
