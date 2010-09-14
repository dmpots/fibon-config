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
  setTimeout $ Limit 2 0 0
  useGhcInPlaceDir "/home/dave/ghc-BUILD/ghc-HEAD-BUILD/inplace/bin"

  if collectStats 
    then do
    append ConfigureFlags "--ghc-option=-rtsopts"
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable"
    else
    done

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build _ _ = done
