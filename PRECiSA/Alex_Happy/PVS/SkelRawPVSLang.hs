module SkelRawPVSLang where

-- Haskell module generated by the BNF converter

import AbsRawPVSLang
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transId :: Id -> Result
transId x = case x of
  Id string -> failure x
transElsIf :: ElsIf -> Result
transElsIf x = case x of
  ElsIf expr1 expr2 -> failure x
transLetElem :: LetElem -> Result
transLetElem x = case x of
  LetElem id expr -> failure x
  LetElemType id1 id2 expr -> failure x
transExpr :: Expr -> Result
transExpr x = case x of
  Let letelems expr -> failure x
  Or expr1 expr2 -> failure x
  And expr1 expr2 -> failure x
  Not expr -> failure x
  Eq expr1 expr2 -> failure x
  Neq expr1 expr2 -> failure x
  Lt expr1 expr2 -> failure x
  LtE expr1 expr2 -> failure x
  Gt expr1 expr2 -> failure x
  GtE expr1 expr2 -> failure x
  ExprAdd expr1 expr2 -> failure x
  ExprSub expr1 expr2 -> failure x
  ExprMul expr1 expr2 -> failure x
  ExprDiv expr1 expr2 -> failure x
  ExprNeg expr -> failure x
  ExprPow expr1 expr2 -> failure x
  If expr1 expr2 expr3 -> failure x
  ListIf expr1 expr2 elsifs expr3 -> failure x
  For integer1 integer2 expr id -> failure x
  Call id exprs -> failure x
  ExprId id -> failure x
  Int integer -> failure x
  Rat double -> failure x
  BTrue -> failure x
  BFalse -> failure x
transSubrange :: Subrange -> Result
transSubrange x = case x of
  SubrageType integer1 integer2 -> failure x
transArg :: Arg -> Result
transArg x = case x of
  FArg ids id -> failure x
  FArgSubrange ids subrange -> failure x
  FArgGuard ids id expr -> failure x
transArgs :: Args -> Result
transArgs x = case x of
  FArgs args -> failure x
  FArgsNoType ids -> failure x
transDecl :: Decl -> Result
transDecl x = case x of
  DeclN id1 args id2 expr -> failure x
  Decl0 id1 id2 expr -> failure x
transImp :: Imp -> Result
transImp x = case x of
  LibImp ids -> failure x
transVarDecl :: VarDecl -> Result
transVarDecl x = case x of
  VarDeclaration id1 id2 -> failure x
transProgram :: Program -> Result
transProgram x = case x of
  ProgImp id1 imp vardecls decls id2 -> failure x
  Prog id1 vardecls decls id2 -> failure x

