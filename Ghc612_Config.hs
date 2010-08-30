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
  , flagsBuilder = flags
  }


flags :: FlagBuilder
flags (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

flags (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

flags (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

flags _ _ = done
