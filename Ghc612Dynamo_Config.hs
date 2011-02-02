module Ghc612Dynamo_Config(
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
build t b = do
  mbOpts <- getEnv "DR_OPTS"
  let opts = maybe "" id mbOpts
  useRunScript dr opts
  (configBuilder Ghc612.config) t b
