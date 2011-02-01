module GhcHead_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "head"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Base, Peak]
  , iterations = 100
  , configBuilder = build
  }

collectStats :: Bool
collectStats = True

standardGHC :: FilePath
standardGHC = "/Research/darcs/ghc-HEAD.BUILD/inplace/bin"

build :: ConfigBuilder
--
-- Default Settings for All Benchmarks
--
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 0 10 0
  append ConfigureFlags "--ghc-option=-rtsopts"

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
  
  -- Setup stats collection 
  if collectStats 
    then do
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable -RTS"
    else
    done

--
-- Default Settings for Specific Benchmarks
--
build (ConfigTuneDefault) (ConfigBench QuickHull) = do
  append RunFlags "+RTS -K64M -RTS"

build (ConfigTuneDefault) (ConfigBench Qsort) = do
  append RunFlags "+RTS -K16M -RTS"

--
-- Base Tune Settings
--
build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench BinaryTrees) = do
  append RunFlags "+RTS -K64M -RTS"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K256M -RTS"

build (ConfigTune Base) (ConfigBench TernaryTrees) = do
  append RunFlags "+RTS -K16M -RTS"

build (ConfigTuneDefault) (ConfigBench Cpsa) = do
  append BuildFlags "--ghc-option=-fcontext-stack=42"

--
-- Peak Tune Settings
--
build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build (ConfigTune Peak) (ConfigBench BinaryTrees) = do
  append RunFlags "+RTS -K32M -RTS"

build (ConfigTune Peak) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

build (ConfigTune Peak) (ConfigBench TernaryTrees) = do
  append RunFlags "+RTS -K16M -RTS"

build _ _ = done
