module GhcPapi_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "papi"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Peak]
  , iterations = 1
  , configBuilder = build
  }

collectStats :: Bool
collectStats = False

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  useGhcInPlaceDir "/home/dave/ghc-BUILD/ghc-PAPI/inplace/bin"
  append ConfigureFlags "--ghc-option=-rtsopts"

  if collectStats 
    then do
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
