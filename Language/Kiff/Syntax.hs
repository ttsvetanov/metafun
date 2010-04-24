module Language.Kiff.Syntax where

type DataName = String
type TvName = String
type TvId = Int
    
data TyPrimitive  = TyInt
                  | TyBool
                  deriving (Eq, Show)

data Ty  = TyVar TvName
         | TyVarId TvId
         | TyFun Ty Ty
         | TyApp Ty Ty
         | TyData DataName
         | TyPrimitive TyPrimitive
         deriving Show


type VarName = String
type ConName = String

data TypeDecl = DataDecl DataName [TvName] [DataCon]
              | TypeAlias DataName [TvName] Ty
              deriving Show
data DataCon = DataCon ConName [Ty] deriving Show
    
data PrimitiveOp  = OpAdd
                  | OpSub
                  | OpMul
                  | OpDiv
                  | OpMod
                  | OpOr
                  | OpAnd
                  | OpEq
                  | OpLe
                  | OpLt
                  | OpGe
                  | OpGt
                  deriving Show
    
data Expr  = Var VarName
           | Con ConName
           | App Expr Expr
           | Lam [Pat] Expr
           | Let [Def] Expr
           | PrimBinOp PrimitiveOp Expr Expr
           | IfThenElse Expr Expr Expr
           | IntLit Int
           | BoolLit Bool
           | UnaryMinus Expr
             deriving Show

data Pat  = PVar VarName
          | PApp ConName [Pat]
          | Wildcard
          | IntPat Int
          | BoolPat Bool
            deriving Show
                     
data DefEq = DefEq [Pat] Expr deriving Show
data Def = Def VarName (Maybe Ty) [DefEq] deriving Show

data Program = Program [TypeDecl] [Def] deriving Show
