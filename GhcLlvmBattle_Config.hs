module GhcLlvmBattle_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "llvm-battle"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }

standardGHC :: FilePath
standardGHC = "/Research/git/ghc/inplace/bin"

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 1 0 0
  append ConfigureFlags "--ghc-option=-rtsopts"
  collectExtraStatsFrom  "ghc.stats"
  append RunFlags "+RTS -tghc.stats --machine-readable -RTS"

  -- Use ghc from standard location off of HOME
  mbHome <- getEnv "HOME"
  maybe done
        (\h -> useGhcInPlaceDir (h ++ standardGHC))
        mbHome

  -- Use ghc specified from environment
  mbHead <- getEnv "FIBON_GHC"
  maybe done
        useGhcInPlaceDir
        mbHead

  append ConfigureFlags "-O2" -- for GHC high-level optimizations
  append ConfigureFlags "--ghc-option=-fllvm"

build (ConfigTune Base) ConfigBenchDefault = do
  --append ConfigureFlags "--ghc-option=-optlo=-disable-opt"
  append ConfigureFlags "--ghc-option=-optlo=-mem2reg"
  append ConfigureFlags "--ghc-option=-optlc=-O1"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--ghc-option=-optlo=-O2"
  append ConfigureFlags "--ghc-option=-optlc=-O2"

build (ConfigTuneDefault) (ConfigBench Cpsa) = do
  append BuildFlags "--ghc-option=-fcontext-stack=42"

build (ConfigTuneDefault) (ConfigBench QuickHull) = do
  append RunFlags "+RTS -K16M -RTS"

build (ConfigTuneDefault) (ConfigBench BinaryTrees) = do
  append RunFlags "+RTS -K32M -RTS"

build (ConfigTuneDefault) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

build (ConfigTuneDefault) (ConfigBench TernaryTrees) = do
  append RunFlags "+RTS -K16M -RTS"

build _ _ = done
