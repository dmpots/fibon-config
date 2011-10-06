module GhcGcBattle_Config(
  config
)
where
import Fibon.Run.Config
import Fibon.ConfigMonad
import qualified GhcHead_Config

config :: RunConfig
config = RunConfig {
    configId = "llvm-gcc"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Base, Peak]
  , iterations = 5
  , configBuilder = build
  }

standardGHC, llvmGccGHC :: FilePath
standardGHC = "/Research/git/ghc/inplace/bin"
llvmGccGHC  = "/Research/git/ghc-clang/inplace/bin"

setGHC :: FilePath -> ConfigMonad
setGHC ghc = do
  -- Use ghc from standard location off of HOME
  mbHome <- getEnv "HOME"
  maybe (error "HOME not set in env")
        (\h -> useGhcInPlaceDir (h ++ ghc))
        mbHome

build :: ConfigBuilder
--
-- Default Settings for All Benchmarks
--
build ConfigTuneDefault ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

  setTimeout $ Limit 0 90 0
  append ConfigureFlags "--ghc-option=-rtsopts"
  append ConfigureFlags "--ghc-option=-threaded"

  -- Setup stats collection 
  collectExtraStatsFrom  "ghc.stats"
  append RunFlags "+RTS -tghc.stats --machine-readable -RTS"

--
-- Base Tune Settings
--
build (ConfigTune Base) ConfigBenchDefault = do
  setGHC standardGHC

--
-- Peak Tune Settings
--
build (ConfigTune Peak) ConfigBenchDefault = do
  setGHC llvmGccGHC 

-- Anything not overridden here will use the standard GHC Head Options
build t b = (configBuilder GhcHead_Config.config) t b

