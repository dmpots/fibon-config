module Ghc610_Config(
  config
)
where
import Fibon.Run.Config
import Fibon.Benchmarks

config :: RunConfig
config = RunConfig {
    configId = "ghc610"
  , runList  = map RunSingle (hackage ++ shootout)
  , sizeList = [Test, Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }
  where
    shootout = filter (\b -> benchGroup b == Shootout) allBenchmarks
    hackage  = filter (\b -> benchGroup b == Hackage && b /= Gf) allBenchmarks

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 3 0 0
  collectExtraStatsFrom  "ghc.stats"
  append RunFlags "+RTS -tghc.stats --machine-readable -RTS"

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K256M -RTS"

build (ConfigTune Base) (ConfigBench TernaryTrees) = do
  append RunFlags "+RTS -K16M -RTS"

build (ConfigTune Base) (ConfigBench BinaryTrees) = do
  append RunFlags "+RTS -K64M -RTS"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build _ _ = do
  done

