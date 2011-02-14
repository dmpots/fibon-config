module GhcLlvmDr_Config(
  config
)
where
import Fibon.Run.Config
import qualified GhcHead_Config as Ghc

config :: RunConfig
config = Ghc.config {
    configId = "drLlvm"
  , configBuilder = build
  }

dr :: FilePath
dr = "/home/dave/dr/bin/drrun"

headConfig :: ConfigBuilder
headConfig = (configBuilder Ghc.config)

build :: ConfigBuilder
build t@ConfigTuneDefault b@ConfigBenchDefault = do
  headConfig t b
  append ConfigureFlags "--ghc-option=-fllvm"

build t@(ConfigTune Peak) b = do
  mbOpts <- getEnv "DR_OPTS"
  let opts = maybe "" id mbOpts
  useRunScript dr opts
  headConfig t b

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"
  -- Do not call head config here because it disables optimization for base

build t b = headConfig t b
