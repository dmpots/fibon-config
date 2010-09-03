module Ghc610_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "ghc610"
  , runList  = map RunSingle $ filter (/= Gf) allBenchmarks
  , sizeList = [Test, Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }

build :: ConfigBuilder
build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K256M -RTS"

build (ConfigTune Base) (ConfigBench TernaryTrees) = do
  append RunFlags "+RTS -K16M -RTS"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build _ _ = do
  done

