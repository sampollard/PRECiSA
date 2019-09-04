module PVSCert where

--import Numeric
import PPExt
import FPrec
import Common.DecisionPath
import Common.ControlFlow
import AbsPVSLang
import AbsSpecLang
import AbstractSemantics
import AbstractDomain
import Kodiak.Runner
import Prelude hiding ((<>))
--import Data.Bits.Floating

addSuffixToFun :: String -> Program -> Program
addSuffixToFun suffix = map (addSuffixToFunDecl suffix)

addSuffixToFunDecl :: String -> Decl -> Decl
addSuffixToFunDecl suffix (Decl fp f args stm) = Decl fp (f++suffix) args (addSuffixToCalls suffix stm)

addSuffixToCalls :: String -> Stm -> Stm
addSuffixToCalls suffix (Let x fp ae stm)          = Let x fp (addSuffixToCallsAE suffix ae)
                                                              (addSuffixToCalls suffix stm)
addSuffixToCalls suffix (Ite be thenStm elseStm)   = Ite (addSuffixToCallsBE suffix be)
                                                         (addSuffixToCalls suffix thenStm)
                                                         (addSuffixToCalls suffix elseStm)
addSuffixToCalls suffix (ListIte thenList elseStm) = ListIte (zip (map (addSuffixToCallsBE suffix . fst) thenList)
                                                                  (map (addSuffixToCalls suffix . snd) thenList))
                                                             (addSuffixToCalls suffix elseStm)
addSuffixToCalls suffix (StmExpr ae)               = StmExpr $ addSuffixToCallsAE suffix ae
addSuffixToCalls suffix (ForLoop fp idxStart idxEnd initAcc idx acc forBody) = ForLoop fp idxStart idxEnd initAcc idx acc (addSuffixToCalls suffix forBody)
addSuffixToCalls _ UnstWarning = UnstWarning

addSuffixToCallsAE :: String -> FAExpr -> FAExpr
addSuffixToCallsAE suffix = replaceInFAExpr (\a -> Nothing) (addSuffixToCall suffix)

addSuffixToCallsBE :: String -> FBExpr -> FBExpr
addSuffixToCallsBE suffix = replaceInFBExpr (\a -> Nothing) (addSuffixToCall suffix)

addSuffixToCall :: String -> FAExpr -> Maybe FAExpr
addSuffixToCall suffix (FEFun f fp args) = Just $ FEFun (f ++ suffix) fp args
addSuffixToCall _ _ = Nothing



genFpProgFile :: String -> Program -> Doc
genFpProgFile progFileName prog =
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text (progFileName ++ ": THEORY")
  $$
  text "BEGIN"
  $$
  prettyDoc (addSuffixToFun "_fp" prog)
  $$
  text ("END " ++ progFileName)


genFpTranProgFile :: String -> Program -> FPrec -> Doc
genFpTranProgFile progFileName prog fp =
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text (progFileName ++ ": THEORY")
  $$
  text "BEGIN\n"
  $$
  text "IMPORTING float@top_ieee754" <> fpDoc fp <+> comma <> text "structures@Maybe[" <> prettyDoc fp <> text "]\n"
  $$
  prettyTranProg prog
  $$
  text ("\n END " ++ progFileName)
    where
      fpDoc FPSingle = text "sp"
      fpDoc FPDouble = text "dp"
      fpDoc _ = error "fpDoc: unexpected value."

genCertFile :: String -> String -> String -> Program -> Interpretation -> Bool -> Doc
genCertFile inputFileName certFileName realFileName prog sem isTran = 
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text (certFileName ++ ": THEORY")
  $$
  text "BEGIN"
  $$
  text ("IMPORTING PRECiSA@strategies, " ++ inputFileName ++ "," ++ realFileName  ++ "\n")
  $$
  text "%|- *_TCC* : PROOF"
  $$
  text "%|- (precisa-gen-cert-tcc)"
  $$
  text "%|- QED\n"
  $$
  printCerts sem prog isTran
  $$
  text ("END " ++ certFileName)

genRealProgFile :: PPExt a => String -> String -> a -> Doc
genRealProgFile inputFileName realProgFileName prog =
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text (realProgFileName ++ ": THEORY")
  $$
  text "BEGIN"
  $$
  text ("IMPORTING " ++ inputFileName ++ "\n")
  $$
  prettyDoc prog
  $$
  text ("END " ++ realProgFileName)

genNumCertFile :: Show a => String -> String -> [(String,FPrec,[Arg],[(Conditions,LDecisionPath,ControlFlow,KodiakResult,AExpr,[FAExpr],[AExpr])])] -> Spec -> Int -> Int -> a -> Bool -> Doc
genNumCertFile certFileName numCertFileName kodiakResult (Spec specBinds) maxDepth prec date isTran =
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text ("% " ++ show date)
  $$
  text ("% maxDepth: " ++ show maxDepth ++ " , prec: 10^-" ++ show prec ++ "\n")
  $$
  text (numCertFileName ++ ": THEORY")
  $$
  text "BEGIN"
  $$
  text ("IMPORTING " ++ certFileName ++ ", PRECiSA@bbiasp, PRECiSA@bbiadp, PRECiSA@strategies \n")
  $$
  text "%|- *_TCC* : PROOF"
  $$
  text "%|- (precisa-gen-cert-tcc)"
  $$
  text "%|- QED\n"
  $$
  printNumCerts kodiakResult specBinds maxDepth prec isTran
  $$
  text ("END " ++ numCertFileName)

prettyTranProg :: Program -> Doc
prettyTranProg decls = vcat (map prettyTranDecl decls)

prettyTranDecl :: Decl -> Doc
prettyTranDecl (Decl fp fun args stm)
      = text fun <> text "(" <>
        hsep (punctuate comma $ map prettyDoc args)
        <> text  "):" <+> text "Maybe[" <> prettyDoc fp <> text "]" <+> text " =" <+> prettyTranSmt stm

prettyTranSmt :: Stm -> Doc
prettyTranSmt UnstWarning = text "None"
prettyTranSmt (Let x t ae stm)
        = text "LET" <+> text x <> text ":" <> prettyDoc t <> text "=" <> prettyDoc ae
            $$ text "IN" <+> prettyTranSmt stm
prettyTranSmt (Ite be stm1 stm2)
        = text "IF" <+> prettyDoc be
            $$ text "THEN" <+> prettyTranSmt stm1
            $$ text "ELSE" <+> prettyTranSmt stm2
            $$ text "ENDIF"
prettyTranSmt (ListIte [] _) = error "prettyDoc RListIte: empty stmThen list"
prettyTranSmt (ListIte ((beThen,stmThen):thenList) stmElse)
        = text "IF" <+> prettyDoc beThen $$ text "THEN" <+> prettyTranSmt stmThen
            $$ vcat (map (\(be,stm) -> text "ELSIF" <+> prettyDoc be
            $$ text "THEN" <+> prettyTranSmt stm) thenList) 
            $$ text "ELSE" <+> prettyTranSmt stmElse $$ text "ENDIF"
prettyTranSmt (StmExpr ae) = text "Some" <> parens (prettyDoc ae)
prettyTranSmt ForLoop{} = undefined


printCerts :: Interpretation -> Program -> Bool -> Doc
printCerts [] _ _ = emptyDoc
printCerts ((f,(fp, args, cset)):interp) decls isTran
  = printLemmasAndProofs fFP fReal args stm cset fp 0
    $$
    printCerts interp decls isTran
  where
    (_,_,stm) = findInDecls f decls
    fFP   = if isTran then f ++ "_fp" else f
    fReal = if isTran then f else f ++ "_real"

printLemmasAndProofs :: String -> String -> [Arg] -> Stm -> ACebS -> FPrec -> Int -> Doc
printLemmasAndProofs _ _ _ _ [] _ _ = emptyDoc
printLemmasAndProofs f fReal args stm (aceb:acebs) fp n
  = prPvsLemma f fReal args aceb fp n
    $$
    prPvsProof f n
    $$
    printLemmasAndProofs f fReal args stm acebs fp (n+1)

prPvsProof :: String -> Int -> Doc
prPvsProof f n =
    text "%|- " <> text f <> text "_" <> int n <> text ": PROOF"
    $$ text "%|- (precisa)"
    $$ text "%|- QED"
    $$ text "\n"

prPvsLemma :: String -> String -> [Arg] -> ACeb -> FPrec -> Int -> Doc
prPvsLemma f fReal args aceb fp n =
  text "% Floating-Point Result:" <+> hsep (punctuate comma $ map prettyDoc fpes)
  $$ text "% Control Flow:"<+> prettyDoc cflow
  $$ text f <> text "_" <> int n <+> text ": LEMMA"
  $$ text "FORALL(" <>  hsep (punctuate comma $ map prErrorInt args)
                    <>  text ": nonneg_real" <> comma
                    <+> hsep (punctuate comma $ map prRealInt args)
                    <>  text ": real" <> comma
                    <+> hsep (punctuate comma $ map prettyDoc args)
                    <> text ")" <> text ":"
  $$ prPvsArgs' args
  $$ text "AND" <+> parens (prettyDoc c)
  $$ text "IMPLIES"
  $$ text "abs(" <> f2r fp (text f <> text "(" <>
     hsep (punctuate comma $ map (prettyDoc . arg2var) args) <> text ")" )
     <+> text "-"
     <+> text fReal <> text "("
     <> hsep (punctuate comma $ map (prettyDoc . realVar . arg2var) args) <> text ")"
     <> text ")"
     <> text "<=" <> prettyDoc err
  $$ text "\n"
  where
    prPvsArgs' arguments = hsep $ punctuate (text " AND") $ map prPVSVarId' arguments
    prPVSVarId' (Arg x t) = text "abs(" <> f2r t (text x)
                                   <+> text "-" <+> text "r_" <> text x <> text ")"
                                   <> text "<=" <> text "e_" <> text x
    prRealInt  (Arg x _) = text "r_" <> text x
    prErrorInt (Arg x _) = text "e_" <> text x
    ACeb {conds = c, fpExprs = fpes, eExpr = err, cFlow = cflow} = aceb

    --realVar (Arg x _) = RealMark x


printNumCerts :: [(String,FPrec,[Arg],[(Conditions,LDecisionPath,ControlFlow,KodiakResult,AExpr,[FAExpr],[AExpr])])] -> [SpecBind] -> Int -> Int -> Bool -> Doc
printNumCerts [] _ _ _ _ = emptyDoc
printNumCerts ((f,fp,args,result):res') spec maxDepth prec isTran =
    printNumCertsFun fFP fReal args result ranges 0 fp prec maxDepth isTran  
    $$
    printNumCerts res' spec maxDepth prec isTran
  where
    ranges = findInSpec f spec
    fFP   = if isTran then f ++ "_fp" else f
    fReal = if isTran then f else f ++ "_real"

printNumCertsFun :: String -> String -> [Arg] -> [(Conditions,LDecisionPath,ControlFlow,KodiakResult,AExpr,[FAExpr],[AExpr])] -> [VarBind] -> Int -> FPrec -> Int -> Int -> Bool -> Doc
printNumCertsFun _ _ _ [] _ _ _ _ _ _ = emptyDoc
printNumCertsFun f fReal args ((cond, _, cflow, res, err, fpes, reales):result') ranges n fp prec maxDepth isTran =
  prInfoLemma cflow fpes reales
  $$
  prPvsNumLemma numLemma f fReal args cond roundOffError ranges fp  Nothing
  $$
  prPvsNumProof numLemma symbLemma prec maxDepth
  $$
  (if isTran then prPvsNumLemma (text f <> text "_err_" <> int n) f fReal args cond roundOffError ranges fp (Just err) else emptyDoc)
  $$
  printNumCertsFun f fReal args result' ranges (n+1) fp prec maxDepth isTran
  where
    numLemma = text f <> text "_c_" <> int n
    roundOffError = maximumUpperBound res
    symbLemma = text f <> text "_" <> int n

prInfoLemma :: ControlFlow -> [FAExpr] -> [AExpr] -> Doc
prInfoLemma cflow fpes reales = text "% Floating-Point Results:"<+> hsep (punctuate comma $ map prettyDoc fpes)
  $$
  text "% Real Results:"<+> hsep (punctuate comma $ map prettyDoc reales)
  $$
  text "% Control Flow: "<+> prettyDoc cflow

prPvsNumProof :: Doc -> Doc -> Int -> Int -> Doc
prPvsNumProof numLemma symbLemma prec maxDepth =
     text "%|-" <+> numLemma <+> text ": PROOF"
  $$ text "%|-" <+> parens (text "prove-concrete-lemma" <+> symbLemma <+> int prec <+> int maxDepth)
  $$ text "%|- QED\n"

prPvsNumLemma :: Doc -> String -> String -> [Arg] -> Conditions -> Double -> [VarBind] -> FPrec -> Maybe AExpr -> Doc
prPvsNumLemma nameLemma f fReal args cond roundOffError ranges fp symbError =
  nameLemma <+> text ": LEMMA"
  $$ text "FORALL(" <>  hsep (punctuate comma $ map (prettyDoc . realVar . arg2var) args)
                    <>  text ": real" <> comma
                    <+> hsep (punctuate comma $ map prettyDoc args) <> text ")" <> text ":"
  $$ prPvsArgs args
  $$ text "AND" <+> parens (prettyDoc cond)
  $$ text "AND" <+> hsep (punctuate (text " AND ") $ map printVarRange ranges)
  $$ text "IMPLIES"
  $$ lhs
  <> text "<="
  <> prettyNumError roundOffError <> text "\n"
  where
    divergence =  text "abs(" 
      <>  f2r fp (text f <> text "("
      <>  hsep (punctuate comma $ map (prettyDoc . arg2var) args) <> text ")")
      <+> text "-"
      <+> text fReal <> text "("
      <>  hsep (punctuate comma $ map (prettyDoc . realVar . arg2var) args) <> text ")"
      <>  text ")"
    lhs = case symbError of
      Nothing -> divergence
      Just err -> prettyDoc err


prPvsArgs :: [Arg] -> Doc
prPvsArgs arguments = hsep $ punctuate (text " AND") $ map (uncurry prPVSVarId . (\a -> (argName a, argPrec a))) arguments

prPVSVarId :: String -> FPrec -> Doc
prPVSVarId x TInt = text "abs("<> text x <+> text "-" <+> text "r_" <> text x <> text ")" <> text "<= 0"
prPVSVarId x fpx  = text "abs(" <> f2r fpx (text x) <+> text "-" <+> text "r_" <> text x <> text ")"
                       <> text "<=" <> prettyDoc (HalfUlp (RealMark x) fpx)


printVarRange :: VarBind -> Doc
printVarRange (VarBind x _ lb ub) =
  text "r_" <> text x <+> text "##" <+> text "[|" <> prettyDoc lb <> comma <> prettyDoc ub <> text "|]"

prettyNumError :: Double -> Doc
prettyNumError = double -- text $ showFFloat Nothing (nextUp' roundOffError) ""

f2r :: FPrec -> Doc -> Doc
f2r fp doc = case fp of
  FPSingle -> text "StoR" <> parens doc
  FPDouble -> text "DtoR" <> parens doc
  TInt -> doc
  t -> error $ "f2r: something went wrong, f2r not defined for " ++ show t


genExprCertFile :: String -> Doc -> Doc
genExprCertFile fileName printTranProgPairs =
  text "% This file is automatically generated by PRECiSA \n"
  $$
  text (fileName ++ ": THEORY")
  $$
  text "BEGIN"
  $$
  text "IMPORTING PRECiSA@strategies, PRECiSA@bbiasp, PRECiSA@bbiadp\n"
  $$
  text "%|- *_TCC* : PROOF"
  $$
  text "%|- (precisa-gen-cert-tcc)"
  $$
  text "%|- QED\n"
  $$
  printTranProgPairs
  $$
  text ("\nEND " ++ fileName)

printSymbExprCert :: FPrec -> String -> [FAExpr] -> [AExpr] -> [AExpr] -> FAExpr -> AExpr -> FBExpr -> EExpr -> Int -> Doc
printSymbExprCert fp f faeVarList errVarList realVarList fae ae be symbErr n =
  text f <> text "_expr_" <> int n <+> text ": LEMMA"
  $$ text "FORALL(" <>  hsep (punctuate comma $ map prettyVarWithType faeVarList)
                    <> comma
                    <+> hsep (punctuate comma $ map prettyDoc errVarList)
                    <>  text ": nonneg_real" <> comma
                    <+> hsep (punctuate comma $ map prettyDoc realVarList)
                    <>  text ": real"
                    <> text ")" <> text ":"
  $$ vcat (map printVarErrBound faeVarList)
  $$ text "AND" <+> parens (prettyDoc be)
  $$ text "IMPLIES"
  $$ text "abs(" <> f2r fp (prettyDoc fae)
     <+> text "-"
     <+> prettyDoc ae <> text ")"
     <+> text "<="
     <+> prettyDoc symbErr
  $$ text "\n%|- " <> text f <> text "_" <> int n <> text ": PROOF"
  $$ text "%|- (precisa)"
  $$ text "%|- QED"
  $$ text "\n"

printNumExprCert :: FPrec -> String -> [FAExpr] -> [AExpr] -> FAExpr -> AExpr -> FBExpr -> Double -> [VarBind] -> Int -> Int -> Int -> Doc
printNumExprCert fp f faeVarList realVarList fae ae be roundOffError ranges n prec maxDepth = 
  text f <> text "_expr_num_" <> int n <+> text ": LEMMA"
  $$ text "FORALL(" <>  hsep (punctuate comma $ map prettyVarWithType faeVarList)
                    <>  comma
                    <+> hsep (punctuate comma $ map prettyDoc realVarList)
                    <>  text ": real"
                    <>  text ")" <> text ":"
  $$ hsep (punctuate (text " AND") $ map (uncurry prPVSVarId . (\a -> (nameFVar a, precFVar a))) faeVarList)
  $$ text "AND"
  <+> parens (prettyDoc be)
  $$ text "AND" <+> hsep (punctuate (text " AND ") $ map printVarRange ranges)
  $$ text "IMPLIES"
  $$ text "abs(" <> f2r fp (prettyDoc fae)
     <+> text "-"
     <+> prettyDoc ae <> text ")"
     <+> text "<="
  <> prettyNumError roundOffError  <> text "\n"
  $$ text "%|-" <+> text f <> text "_c_" <> int n <+> text ": PROOF"
  $$ text "%|-" <+> parens (text "prove-concrete-lemma" <+> text f <> text "_expr_" <> int n <+> int prec <+> int maxDepth)
  $$ text "%|- QED\n"

printVarErrBound :: FAExpr -> Doc
printVarErrBound var@(FVar _ _) = text "abs(" <> prettyDoc var <> text "-" <> prettyDoc (realVar var) <> text ") <=" <> prettyDoc (errVar var)
printVarErrBound ae = error $ "printVarErrBound: case " ++ show ae ++ " not expected."

printExprFunCert :: FPrec -> (Decl, [(FAExpr,AExpr,FBExpr,EExpr,Double,[FAExpr],[AExpr],[EExpr],[VarBind])]) -> Doc
printExprFunCert fp (Decl _ f _ _, exprList) = vcat $ zipWith (printExprCert' fp f) exprList [1, 2 ..]


printExprCert' :: FPrec -> String -> (FAExpr,AExpr,FBExpr,EExpr,Double,[FAExpr],[AExpr],[EExpr],[VarBind]) -> Int -> Doc
printExprCert' fp f (fae, ae, be, symbErr, numErr, faeVarList, realVarList, errVarList,varBinds) n =
  printSymbExprCert fp f faeVarList errVarList realVarList fae ae be symbErr n
  $$
  printNumExprCert fp f faeVarList realVarList fae ae be numErr varBinds n 14 7 


