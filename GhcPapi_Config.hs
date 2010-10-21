module GhcPapi_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "papi"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Peak]
  , iterations = 1
  , configBuilder = build
  }

collectStats :: Bool
collectStats = False

standardGHC :: FilePath
standardGHC = "/Research/darcs/ghc-PAPI.BUILD/inplace/bin"

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  append ConfigureFlags "--ghc-option=-rtsopts"

  -- Use ghc from standard location off of HOME
  mbHome <- getEnv "HOME"
  maybe done
        (\h -> useGhcInPlaceDir (h ++ standardGHC))
        mbHome

  -- Use ghc specified from environment
  mbHead <- getEnv "FIBON_GHC_HEAD"
  maybe done
        useGhcInPlaceDir
        mbHead

  if collectStats 
    then do
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable"
    else
    done

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "--disable-optimization"

build (ConfigTune Base) (ConfigBench Palindromes) = do
  append RunFlags "+RTS -K128M -RTS"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "--enable-optimization=2"

build (ConfigTuneDefault) (ConfigBench Cpsa) = do
  append BuildFlags "--ghc-option=-fcontext-stack=42"

build (ConfigTuneDefault) (ConfigBench QuickHull) = do
  append RunFlags "+RTS -K16M -RTS"

build _ _ = done
