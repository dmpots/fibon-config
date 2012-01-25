module GhcTrace_Config(
  config
)
where
import Fibon.Run.Config
import qualified GhcHead_Config as GhcHead

config :: RunConfig
config = GhcHead.config {
    configId = "ghc-trace"
  , sizeList      = [Train]
  , tuneList      = [Base, Peak]
  , configBuilder = build
  }

standardGHC :: FilePath
standardGHC = "/Research/git/ghc-trace/inplace/bin"

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 0 60 0
  -- Use ghc from standard location off of HOME otherwise
  mbHome <- getEnv "HOME"
  maybe (error "Unable to get HOME path")
    (\h -> useGhcInPlaceDir (h ++ standardGHC))
    mbHome

  -- Set ghc options
  append ConfigureFlags "--ghc-option=-fllvm"

  -- Setup stats collection 
  append ConfigureFlags "--ghc-option=-rtsopts"
  collectExtraStatsFrom  "ghc.stats"
  append RunFlags "+RTS -tghc.stats --machine-readable -RTS"
  
-- Use Same settings for peak and base tunes
build (ConfigTune Base) b = build (ConfigTune Peak) b
  
build t b = (configBuilder GhcHead.config) t b
