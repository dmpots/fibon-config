module Ghc612Dr_Config(
  config
)
where
import Fibon.Run.Config
import qualified Ghc612_Config as Ghc612

config :: RunConfig
config = Ghc612.config {
    configId = "dr612"
  , configBuilder = build
  }

dr :: FilePath
dr = "/home/dave/dr/bin/drrun"

build :: ConfigBuilder
build t@(ConfigTune Peak) b = do
  mbOpts <- getEnv "DR_OPTS"
  let opts = maybe "" id mbOpts
  useRunScript dr opts
  (configBuilder Ghc612.config) t b

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build t b = (configBuilder Ghc612.config) t b
