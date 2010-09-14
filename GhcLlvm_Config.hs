module GhcLlvm_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "llvm"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }

collectStats :: Bool
collectStats = True

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  useGhcInPlaceDir "/home/dave/ghc-BUILD/ghc-HEAD-BUILD/inplace/bin"

  if collectStats 
    then do
    append ConfigureFlags "--ghc-option=-rtsopts"
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable"
    else
    done

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "-O2"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "-O2"
  append ConfigureFlags "--ghc-option=-fllvm"

build _ _ = done
