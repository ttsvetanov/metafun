module Metafun where

import Metafun.Compiler
import Metafun.Compiler.State
    
import qualified Language.Kiff.Syntax as Kiff
import qualified Language.CxxMPL.Syntax as MPL

import Language.Kiff.Parser
import Language.Kiff.Typing
import Language.Kiff.Typing.Infer
import Language.CxxMPL.Unparser

import Control.Monad.State (evalState)
import System.Path (splitExt)
import Text.PrettyPrint (render)
import Data.Supply
import System.Environment (getArgs, getProgName)
    
mkIds :: IO (Supply Kiff.TvId)
mkIds = newEnumSupply

compileFile filename = do
  parseRes <- parseFile filename
  case parseRes of
    Left errors -> do print errors
                      return Nothing
    Right prog@(Kiff.Program decls defs) -> do
                         ids <- mkIds
                         let (ids', ids'') = split2 ids
                             ctx = mkCtx ids'
                         case inferDefs ids'' ctx defs of
                           Left errors -> do putStrLn $ unlines $ map show errors
                                             return Nothing
                           Right (ctx', tdefs) -> do let tprog = Kiff.Program decls tdefs
                                                         defs = runCompiler (compile tprog)
                                                         mpl = MPL.Program defs
                                                     return $ Just mpl

main' filename = do putStrLn $ unwords ["Compiling", filename]
                    compileRes <- compileFile filename
                    case compileRes of
                      Nothing -> return ()
                      Just mpl -> do putStrLn $ unwords ["Creating", filename']
                                     writeFile filename' $ render $ unparse mpl
    where (fname, ext) = splitExt filename
          filename' = (if ext == ".kiff" then fname else filename) ++ ".cc"
                                                                       
test = main' "lorentey-c++-tmp.kiff"

main = do args <- getArgs          
          case args of
            [filename] -> main' filename
            _ -> do progname <- getProgName
                    error $ unwords ["Usage:", progname, "inputfile.kiff"]
