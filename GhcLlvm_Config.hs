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
  append ConfigureFlags "--ghc-option=-rtsopts"
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
  append ConfigureFlags "-O2"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "-O2"
  append ConfigureFlags "--ghc-option=-fllvm"

build _ _ = done
