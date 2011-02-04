module GhcHeadDr_Config(
  config
)
where
import Fibon.Run.Config
import qualified GhcHead_Config as Ghc

config :: RunConfig
config = Ghc.config {
    configId = "drHead"
  , configBuilder = build
  }

dr :: FilePath
dr = "/home/dave/dr/bin/drrun"

build :: ConfigBuilder
build t@(ConfigTune Peak) b = do
  mbOpts <- getEnv "DR_OPTS"
  let opts = maybe "" id mbOpts
  useRunScript dr opts
  (configBuilder Ghc.config) t b

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build t b = (configBuilder Ghc.config) t b
