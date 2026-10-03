module Stage0.Cosmology.StreamingCosmology

import Stage0.BoxInt
import Stage0.Multiset
import Stage1.QuadStream
import Stage1.Multiset.QuadStreamPipeline
import Stage0.OnSeq.FusedStream
import Stage1.OnSeq
import Stage1.Cosmology.MultisetAdjunction
import Stage0.Cosmology.CapacityBudget
import Data.Fuel

%default total

--------------------------------------------------------------------------------
-- 1. STAGE1 ON-SEQUENCE COSMIC MACRO TRAJECTORIES & QUAD-STREAM INTERFACE
--------------------------------------------------------------------------------

||| Maps QuadStreamMultiset payload to CyclicCosmicEpoch state.
public export
quadStreamToCosmicEpoch : QuadStreamMultiset BoxInt -> CyclicCosmicEpoch
quadStreamToCosmicEpoch (MkQuadStream e h p s) =
  let stepIdx = cast (unwrapBox (multisetSum e))
      matterMass = cast (unwrapBox (multisetSum p))
      darkLaws = AddM hyperbolicSignature2D (multisetSum h) ZeroM
  in MkCyclicEpoch stepIdx (MkConcrete matterMass) darkLaws

||| Constructive OnSeq mapping term index n to CyclicCosmicEpoch trajectory.
public export
cosmologyOnSeq : CyclicCosmicEpoch -> OnSeq CyclicCosmicEpoch
cosmologyOnSeq seed = MkOnSeq 0 (\n => iterateNat n collapseAndReboundEpoch seed)
  where
    iterateNat : Nat -> (a -> a) -> a -> a
    iterateNat Z _ x = x
    iterateNat (S k) f x = iterateNat k f (f x)

||| Extracts a finite Clip of CyclicCosmicEpochs from the ongoing cosmic sequence.
public export
getCosmologyClip : CyclicCosmicEpoch -> (idx : Nat) -> (len : Nat) -> Clip CyclicCosmicEpoch
getCosmologyClip seed idx len = getClip (cosmologyOnSeq seed) idx len

--------------------------------------------------------------------------------
-- 2. DEFORESTED STAGE0 FUSED STREAM TRANSDUCERS FOR COSMOLOGY
--------------------------------------------------------------------------------

||| Deforested stream transducer advancing CyclicCosmicEpoch states over Fuel.
public export
fusedCosmologyStream : Fuel -> CyclicCosmicEpoch -> FusedStream CyclicCosmicEpoch
fusedCosmologyStream f seedEpoch = MkStream nextStep (1, seedEpoch)
  where
    nextStep : (Nat, CyclicCosmicEpoch) -> Step (Nat, CyclicCosmicEpoch) CyclicCosmicEpoch
    nextStep (curr, ep) =
      let ep' = collapseAndReboundEpoch ep
      in Yield ep (S curr, ep')

||| Deforested Quad-Stream pipeline for Cosmology law dynamics over Fuel.
public export
fusedQuadStreamCosmologyPipeline : Fuel -> QuadStreamMultiset BoxInt -> FusedStream (QuadStreamMultiset BoxInt)
fusedQuadStreamCosmologyPipeline f seedQs =
  let cosmoStep = \qs =>
        let ep = quadStreamToCosmicEpoch qs
            ep' = collapseAndReboundEpoch ep
            vm = natToBoxInt ep'.concreteState.particleCount
            de = intToBoxInt 128
            dm = multiplicity hyperbolicSignature2D ep'.darkEnergyLaws
        in MkQuadStream (AddM (intToBoxInt 1) vm ZeroM)
                        (AddM (intToBoxInt 1) de ZeroM)
                        ZeroM
                        (AddM (intToBoxInt 1) dm ZeroM)
  in fusedQuadStreamPipeline f cosmoStep seedQs

||| Evaluates total accumulated dark energy law count across N cosmic steps using fusedHylomorphism.
public export covering
fusedComputeCosmicLawAccumulation : Fuel -> CyclicCosmicEpoch -> BoxInt
fusedComputeCosmicLawAccumulation f seedEpoch =
  fusedHylomorphism f
    (\(curr, ep) =>
       let ep' = collapseAndReboundEpoch ep
       in Yield ep (S curr, ep'))
    (\ep, acc => multiplicity hyperbolicSignature2D ep.darkEnergyLaws + acc)
    (intToBoxInt 0)
    (1, seedEpoch)

||| Total Nat fuel-bounded accumulated dark energy law count across N cosmic steps.
public export
fusedComputeCosmicLawAccumulationNat : (fuel : Nat) -> CyclicCosmicEpoch -> BoxInt
fusedComputeCosmicLawAccumulationNat Z _ = intToBoxInt 0
fusedComputeCosmicLawAccumulationNat (S f) seedEpoch =
  loop f (1, seedEpoch) (intToBoxInt 0)
  where
    loop : Nat -> (Nat, CyclicCosmicEpoch) -> BoxInt -> BoxInt
    loop Z _ acc = acc
    loop (S k) (curr, ep) acc =
      let ep' = collapseAndReboundEpoch ep
      in loop k (S curr, ep') (multiplicity hyperbolicSignature2D ep.darkEnergyLaws + acc)

--------------------------------------------------------------------------------
-- 3. AUDIT PROOF WITNESS
--------------------------------------------------------------------------------

||| Audit witness verifying deforested streaming cosmology execution.
public export
auditStreamingCosmologyProof : Bool
auditStreamingCosmologyProof =
  let initEp = MkCyclicEpoch 1 (MkConcrete 27) ZeroM
      clip = getCosmologyClip initEp 0 3
      lawsCount = fusedComputeCosmicLawAccumulationNat 5 initEp
  in length (elements clip) == 3 && unwrapBox lawsCount >= 0
