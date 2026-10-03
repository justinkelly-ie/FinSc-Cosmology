module Stage0.Cosmology.MetricLawLedger

import public Stage0.BoxInt
import public Stage0.Multiset
import public Stage1.MetricSignature

%default total

--------------------------------------------------------------------------------
-- 1. CHROMOGEOMETRIC DARK ENERGY LAW TOKENS
--------------------------------------------------------------------------------

||| Chromogeometric Dark Energy Law Tokens representing metric signatures
||| persisting across cosmic contraction cycles into the dark energy residue ledger.
public export
data ChromogeometryLaw =
    EllipticRed        -- Elliptic metric signature (det > 0, Matter Canvas)
  | HyperbolicGreen    -- Hyperbolic metric signature (det < 0, Relativistic EM)
  | ParabolicBlue      -- Parabolic metric signature (det == 0, Rational Trig Spread)
  | SubstrateTorsion   -- Substrate metric signature (det < 0, Asymmetric Causal Poset)

public export
Eq ChromogeometryLaw where
  EllipticRed      == EllipticRed      = True
  HyperbolicGreen  == HyperbolicGreen  = True
  ParabolicBlue    == ParabolicBlue    = True
  SubstrateTorsion == SubstrateTorsion = True
  _                == _                = False

public export
Show ChromogeometryLaw where
  show EllipticRed      = "Elliptic(Red)"
  show HyperbolicGreen  = "Hyperbolic(Green)"
  show ParabolicBlue    = "Parabolic(Blue)"
  show SubstrateTorsion = "Substrate(Torsion)"

--------------------------------------------------------------------------------
-- 2. CHROMOGEOMETRY DARK ENERGY MULTISET LAW LEDGER
--------------------------------------------------------------------------------

||| Dark Energy Law Multiset Ledger tracking law counts over BoxInt multiplicities.
public export
ChromogeometryLawLedger : Type
ChromogeometryLawLedger = Multiset BoxInt ChromogeometryLaw

||| Empty Multiset Bootstrap State (Genesis Vacuum State for Epoch 1)
public export
emptyLawLedger : ChromogeometryLawLedger
emptyLawLedger = ZeroM

||| Computes total dark energy law count across all metric signatures in the multiset.
public export
countTotalDarkLaws : ChromogeometryLawLedger -> Nat
countTotalDarkLaws ZeroM = 0
countTotalDarkLaws (AddM _ v rest) = boxToNat v + countTotalDarkLaws rest

--------------------------------------------------------------------------------
-- 3. CANONICAL MULTISET METRIC SIGNATURE LEDGER & QUADRANCE EVALUATION
--------------------------------------------------------------------------------

||| Canonical pure multiset metric signature ledger tracking actual discrete metric tensors.
public export
CosmicMetricLedger : Type
CosmicMetricLedger = Multiset BoxInt MetricSignature

||| Isomorphism mapping ChromogeometryLaw tokens to canonical MetricSignature records.
public export
chromogeometryLawToSignature : ChromogeometryLaw -> MetricSignature
chromogeometryLawToSignature EllipticRed      = ellipticSignature2D
chromogeometryLawToSignature HyperbolicGreen  = hyperbolicSignature2D
chromogeometryLawToSignature ParabolicBlue    = parabolicSignature2D
chromogeometryLawToSignature SubstrateTorsion = substrateSignature2D

||| Converts a legacy ChromogeometryLawLedger into a canonical CosmicMetricLedger.
public export
lawLedgerToMetricLedger : ChromogeometryLawLedger -> CosmicMetricLedger
lawLedgerToMetricLedger ZeroM = ZeroM
lawLedgerToMetricLedger (AddM law w rest) =
  AddM (chromogeometryLawToSignature law) w (lawLedgerToMetricLedger rest)

||| Computes total law count across a CosmicMetricLedger.
public export
countMetricLedgerLaws : CosmicMetricLedger -> Nat
countMetricLedgerLaws ZeroM = 0
countMetricLedgerLaws (AddM _ v rest) = boxToNat v + countMetricLedgerLaws rest

||| Evaluates discrete aggregate quadrance across the entire multiset metric ledger for coordinates x and y.
public export
evaluateMetricLedgerQuadrance : CosmicMetricLedger -> BoxInt -> BoxInt -> BoxInt
evaluateMetricLedgerQuadrance ZeroM _ _ = intToBoxInt 0
evaluateMetricLedgerQuadrance (AddM sig w rest) x y =
  let q = signatureQuadrance2D sig x y
  in (q * w) + evaluateMetricLedgerQuadrance rest x y
