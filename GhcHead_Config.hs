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

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 0 10 0
  append ConfigureFlags "--ghc-option=-rtsopts"

  -- take the GHC head dir from the environment if set from there
  mbHead <- getEnv "FIBON_GHC_HEAD"
  maybe (useGhcInPlaceDir "/home/dave/ghc-BUILD/ghc-HEAD-BUILD/inplace/bin")
         useGhcInPlaceDir
         mbHead

  if collectStats 
    then do
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable"
    else
    done

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

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build _ _ = done
