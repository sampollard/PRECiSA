-- File generated by the BNF Converter (bnfc 2.9.5).

-- Templates for pattern matching on abstract syntax

{-# OPTIONS_GHC -fno-warn-unused-matches #-}

module SkelRawPVSLang where

import Prelude (($), Either(..), String, (++), Show, show)
import qualified AbsRawPVSLang

type Err = Either String
type Result = Err String

failure :: Show a => a -> Result
failure x = Left $ "Undefined case: " ++ show x

transId :: AbsRawPVSLang.Id -> Result
transId x = case x of
  AbsRawPVSLang.Id string -> failure x

transElsIf :: AbsRawPVSLang.ElsIf -> Result
transElsIf x = case x of
  AbsRawPVSLang.ElsIf expr1 expr2 -> failure x

transLetElem :: AbsRawPVSLang.LetElem -> Result
transLetElem x = case x of
  AbsRawPVSLang.LetElem id expr -> failure x
  AbsRawPVSLang.LetElemType id type_ expr -> failure x

transRecordElem :: AbsRawPVSLang.RecordElem -> Result
transRecordElem x = case x of
  AbsRawPVSLang.RecordElem id expr -> failure x

transLambdaKeyWord :: AbsRawPVSLang.LambdaKeyWord -> Result
transLambdaKeyWord x = case x of
  AbsRawPVSLang.LambdaWord1 -> failure x
  AbsRawPVSLang.LambdaWord2 -> failure x

transLambdaExpr :: AbsRawPVSLang.LambdaExpr -> Result
transLambdaExpr x = case x of
  AbsRawPVSLang.Lambda lambdakeyword id1 expr1 expr2 id2 type_ expr3 -> failure x

transExpr :: AbsRawPVSLang.Expr -> Result
transExpr x = case x of
  AbsRawPVSLang.Let letelems expr -> failure x
  AbsRawPVSLang.Or expr1 expr2 -> failure x
  AbsRawPVSLang.And expr1 expr2 -> failure x
  AbsRawPVSLang.Not expr -> failure x
  AbsRawPVSLang.Eq expr1 expr2 -> failure x
  AbsRawPVSLang.Neq expr1 expr2 -> failure x
  AbsRawPVSLang.Lt expr1 expr2 -> failure x
  AbsRawPVSLang.LtE expr1 expr2 -> failure x
  AbsRawPVSLang.Gt expr1 expr2 -> failure x
  AbsRawPVSLang.GtE expr1 expr2 -> failure x
  AbsRawPVSLang.ExprAdd expr1 expr2 -> failure x
  AbsRawPVSLang.ExprSub expr1 expr2 -> failure x
  AbsRawPVSLang.ExprMul expr1 expr2 -> failure x
  AbsRawPVSLang.ExprDiv expr1 expr2 -> failure x
  AbsRawPVSLang.With expr1 expr2 expr3 -> failure x
  AbsRawPVSLang.ExprNeg expr -> failure x
  AbsRawPVSLang.ExprPow expr1 expr2 -> failure x
  AbsRawPVSLang.If expr1 expr2 expr3 -> failure x
  AbsRawPVSLang.ListIf expr1 expr2 elsifs expr3 -> failure x
  AbsRawPVSLang.For expr1 expr2 expr3 lambdaexpr -> failure x
  AbsRawPVSLang.ForDown expr1 expr2 expr3 lambdaexpr -> failure x
  AbsRawPVSLang.TupleIndex id integer -> failure x
  AbsRawPVSLang.RecordField id1 id2 -> failure x
  AbsRawPVSLang.TupleFunIndex id exprs integer -> failure x
  AbsRawPVSLang.RecordFunField id1 exprs id2 -> failure x
  AbsRawPVSLang.RecordExpr recordelems -> failure x
  AbsRawPVSLang.TupleExpr exprs -> failure x
  AbsRawPVSLang.Call id exprs -> failure x
  AbsRawPVSLang.ExprId id -> failure x
  AbsRawPVSLang.Int integer -> failure x
  AbsRawPVSLang.Rat double -> failure x
  AbsRawPVSLang.BTrue -> failure x
  AbsRawPVSLang.BFalse -> failure x

transFieldDecls :: AbsRawPVSLang.FieldDecls -> Result
transFieldDecls x = case x of
  AbsRawPVSLang.FieldDecls id type_ -> failure x

transType :: AbsRawPVSLang.Type -> Result
transType x = case x of
  AbsRawPVSLang.TypeSimple id -> failure x
  AbsRawPVSLang.ParametricTypeBi id integer1 integer2 -> failure x
  AbsRawPVSLang.TypeBelow expr -> failure x
  AbsRawPVSLang.TypeRecord fielddeclss -> failure x
  AbsRawPVSLang.TypeTuple types -> failure x
  AbsRawPVSLang.TypeArray types type_ -> failure x
  AbsRawPVSLang.TypeFun types type_ -> failure x
  AbsRawPVSLang.TypeFun2 types type_ -> failure x
  AbsRawPVSLang.TypeList type_ -> failure x

transArg :: AbsRawPVSLang.Arg -> Result
transArg x = case x of
  AbsRawPVSLang.FArg ids type_ -> failure x
  AbsRawPVSLang.FArgGuard ids type_ expr -> failure x

transArgs :: AbsRawPVSLang.Args -> Result
transArgs x = case x of
  AbsRawPVSLang.FArgs args -> failure x
  AbsRawPVSLang.FArgsNoType ids -> failure x

transDecl :: AbsRawPVSLang.Decl -> Result
transDecl x = case x of
  AbsRawPVSLang.DeclN id args type_ expr -> failure x
  AbsRawPVSLang.Decl0 id type_ expr -> failure x

transImp :: AbsRawPVSLang.Imp -> Result
transImp x = case x of
  AbsRawPVSLang.LibImp ids -> failure x

transProgram :: AbsRawPVSLang.Program -> Result
transProgram x = case x of
  AbsRawPVSLang.ProgImp id1 imp decls id2 -> failure x
  AbsRawPVSLang.Prog id1 decls id2 -> failure x