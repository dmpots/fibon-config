module Ghc74_Config(
  config
)
where
import Fibon.Run.Config
import qualified GhcHead_Config as Ghc

config :: RunConfig
config = Ghc.config {
    configId = "ghc-7.4"
  , sizeList      = [Ref]
  , tuneList      = [Peak]
  , configBuilder = build
  }

standardGHC :: FilePath
standardGHC = "/Research/git/ghc-7.4/inplace/bin"

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 0 60 0
  append ConfigureFlags "--ghc-option=-rtsopts"

  -- Use ghc from standard location off of HOME otherwise
  mbHome <- getEnv "HOME"
  maybe (error "Unable to get HOME path")
    (\h -> useGhcInPlaceDir (h ++ standardGHC))
    mbHome

  -- Setup stats collection 
  collectExtraStatsFrom  "ghc.stats"
  append RunFlags "+RTS -tghc.stats --machine-readable -RTS"
  

build t b = (configBuilder Ghc.config) t b
