# Extensive Test Report

## Run Metadata
- Timestamp: 2025-12-31 15:25:09 EST
- Commit: `431738a` (dirty: 28 modified, 9 untracked)
- Forge: forge Version: 1.5.0-stable; Commit SHA: 1c57854462289b2e71ee7654cd6666217ed86ffd; Build Timestamp: 2025-11-26T09:16:58.269730000Z (1764148618); Build Profile: maxperf
- Profile: `long` (fuzz runs 10000, invariant runs 2000, depth 1000)
- Command: `env FOUNDRY_PROFILE=long /usr/bin/time -p -o cache/long-test.time forge test --json > cache/long-test.json`
- Runtime (from `/usr/bin/time`): real 1225.38s, user 2548.0s, sys 11.92s

## Overall Results
- Suites: 11
- Tests: 107 (passed 106, failed 0, skipped 1)
- Skipped: `test/PoidhV3.fork.t.sol:PoidhV3ForkTest` `setUp()` (skipped: FORK_URL not set)

## Per-Suite Results
| Suite | Tests | Passed | Failed | Skipped |
| --- | --- | --- | --- | --- |
| test/Deploy.t.sol:DeployScriptTest | 1 | 1 | 0 | 0 |
| test/PoidhClaimNFT.t.sol:PoidhClaimNFTTest | 3 | 3 | 0 | 0 |
| test/PoidhV3.attack.t.sol:PoidhV3AttackTest | 20 | 20 | 0 | 0 |
| test/PoidhV3.coverage.t.sol:PoidhV3CoverageTest | 25 | 25 | 0 | 0 |
| test/PoidhV3.fork.t.sol:PoidhV3ForkTest | 1 | 0 | 0 | 1 |
| test/PoidhV3.fuzz.t.sol:PoidhV3FuzzTest | 2 | 2 | 0 | 0 |
| test/PoidhV3.griefing.t.sol:PoidhV3GriefingTest | 12 | 12 | 0 | 0 |
| test/PoidhV3.invariant.t.sol:PoidhV3InvariantTest | 4 | 4 | 0 | 0 |
| test/PoidhV3.simulation.t.sol:PoidhV3SimulationTest | 1 | 1 | 0 | 0 |
| test/PoidhV3.t.sol:PoidhV3Test | 3 | 3 | 0 | 0 |
| test/PoidhV3.unit.t.sol:PoidhV3UnitTest | 35 | 35 | 0 | 0 |

## Unit Test Gas (Unit-kind tests)
- Count: 101
- Min gas: 0
- Median gas: 715675
- Mean gas: 1437183
- Max gas: 12470027

## Fuzz Tests
- `test/PoidhV3.fuzz.t.sol:PoidhV3FuzzTest` `testFuzz_open_vote_outcome_matches_majority(uint96,uint96,bool)` runs=10000 mean_gas=1037659 median_gas=1070085 failed_corpus_replays=0
- `test/PoidhV3.fuzz.t.sol:PoidhV3FuzzTest` `testFuzz_solo_acceptClaim_feeAccounting(uint96)` runs=10000 mean_gas=668001 median_gas=668090 failed_corpus_replays=0

## Invariant Tests
- `test/PoidhV3.invariant.t.sol:PoidhV3InvariantTest` `invariant_claimedBountiesFinalized_and_nftDelivered()` runs=2000 calls=2000000 reverts=169090 failed_corpus_replays=0
  Top handler reverts (reverts/calls):
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelSolo: 55301/167011
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.joinOpen: 54004/166917
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelOpen: 53830/166512
- `test/PoidhV3.invariant.t.sol:PoidhV3InvariantTest` `invariant_noPendingWithdrawalsToZeroAddress()` runs=2000 calls=2000000 reverts=168437 failed_corpus_replays=0
  Top handler reverts (reverts/calls):
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelSolo: 55350/167223
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelOpen: 53652/166708
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.joinOpen: 53400/166466
- `test/PoidhV3.invariant.t.sol:PoidhV3InvariantTest` `invariant_openBountyAmountMatchesParticipantSums_unless_claimed()` runs=2000 calls=2000000 reverts=167897 failed_corpus_replays=0
  Top handler reverts (reverts/calls):
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelSolo: 55265/166319
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.joinOpen: 53500/166943
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelOpen: 53172/166929
- `test/PoidhV3.invariant.t.sol:PoidhV3InvariantTest` `invariant_votingState_is_consistent()` runs=2000 calls=2000000 reverts=169305 failed_corpus_replays=0
  Top handler reverts (reverts/calls):
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelSolo: 55333/166357
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.joinOpen: 54133/166965
  - test/PoidhV3.invariant.t.sol:PoidhV3Handler.cancelOpen: 53830/166874

## Simulation Runs (Voting Monte Carlo)
- Command (batch): `forge script script/Simulate.s.sol:Simulate --sig "runVoting(uint256,uint256,uint256,uint256)" -q -- 1 50 99 6000`
- Batches: 200
- Runs per batch: 50
- Total runs: 10000
- Batch elapsed (approx): 123.41s
- Passed: 9400 (passBps 9400)
- Parameters (seed, participants, yesBps, issuerAmount, minJoin, maxJoin):
  - seed=1, participants=99, yesBps=6000, issuerAmount=1000000000000000000, minJoin=10000000000000, maxJoin=1000000000000000000 (batches=200)
- Avg yes per run: 3.057248e+19 wei (30.572480 ether)
- Avg no per run: 1.988550e+19 wei (19.885504 ether)
- Avg total per run: 5.045798e+19 wei (50.457984 ether)

## Simulation Run (Slot Exhaustion)
- Command: `forge script script/Simulate.s.sol:Simulate --sig "runSlotExhaustion()"`
- Output: slotExhaustion_blockedNewJoin=false, participantsArrayLength=150

## Artifacts
- `cache/long-test.json`
- `cache/long-test-summary.json`
- `cache/long-test.time`
- `cache/simulations/voting-summary-*.json` (latest 200 used for aggregation)
- `cache/simulations/voting-*.jsonl`
