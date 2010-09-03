module Ghc612_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "ghc612"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Test, Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }


build :: ConfigBuilder
build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build _ _ = done
