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
Ord ChromogeometryLaw where
  compare x y = compare (tag x) (tag y)
    where
      tag : ChromogeometryLaw -> Nat
      tag EllipticRed      = 0
      tag HyperbolicGreen  = 1
      tag ParabolicBlue    = 2
      tag SubstrateTorsion = 3

public export
DiscreteCoord ChromogeometryLaw where

public export
DiscreteCoord MetricSignature where

public export
Show ChromogeometryLaw where
  show EllipticRed      = "Elliptic(Red)"
  show HyperbolicGreen  = "Hyperbolic(Green)"
  show ParabolicBlue    = "Parabolic(Blue)"
  show SubstrateTorsion = "Substrate(Torsion)"

--------------------------------------------------------------------------------
-- 2. CHROMOGEOMETRY DARK ENERGY MULTISET LAW LEDGER
--------------------------------------------------------------------------------

||| Dark Energy Law Carrier Ledger tracking law counts over BoxInt multiplicities.
public export
ChromogeometryLawLedger : Type
ChromogeometryLawLedger = Carrier ChromogeometryLaw

||| Empty Carrier Bootstrap State (Genesis Vacuum State for Epoch 1)
public export
emptyLawLedger : ChromogeometryLawLedger
emptyLawLedger = BoxLeaf

||| Computes total dark energy law count across all metric signatures in the carrier.
public export
countTotalDarkLaws : ChromogeometryLawLedger -> Nat
countTotalDarkLaws = foldBoxTreeL (\acc, (_, v) => boxToNat v + acc) 0

--------------------------------------------------------------------------------
-- 3. CANONICAL CARRIER METRIC SIGNATURE LEDGER & QUADRANCE EVALUATION
--------------------------------------------------------------------------------

||| Canonical carrier metric signature ledger tracking discrete metric signatures.
public export
CosmicMetricLedger : Type
CosmicMetricLedger = Carrier MetricSignature

||| Isomorphism mapping ChromogeometryLaw tokens to canonical MetricSignature records.
public export
chromogeometryLawToSignature : ChromogeometryLaw -> MetricSignature
chromogeometryLawToSignature EllipticRed      = ellipticSignature2D
chromogeometryLawToSignature HyperbolicGreen  = hyperbolicSignature2D
chromogeometryLawToSignature ParabolicBlue    = parabolicSignature2D
chromogeometryLawToSignature SubstrateTorsion = substrateSignature2D

||| Converts a ChromogeometryLawLedger into a canonical CosmicMetricLedger.
public export
lawLedgerToMetricLedger : ChromogeometryLawLedger -> CosmicMetricLedger
lawLedgerToMetricLedger = pushforwardCarrier chromogeometryLawToSignature

||| Computes total law count across a CosmicMetricLedger.
public export
countMetricLedgerLaws : CosmicMetricLedger -> Nat
countMetricLedgerLaws = foldBoxTreeL (\acc, (_, v) => boxToNat v + acc) 0

||| Evaluates discrete aggregate quadrance across the entire carrier metric ledger for coordinates x and y.
public export
evaluateMetricLedgerQuadrance : CosmicMetricLedger -> BoxInt -> BoxInt -> BoxInt
evaluateMetricLedgerQuadrance ledger x y =
  foldBoxTreeL (\acc, (sig, w) => (signatureQuadrance2D sig x y * w) + acc) (intToBoxInt 0) ledger
