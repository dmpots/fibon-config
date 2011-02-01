module GhcLlvm_Config(
  config
)
where
import Fibon.Run.Config

config :: RunConfig
config = RunConfig {
    configId = "llvm"
  , runList  = map RunSingle allBenchmarks
  , sizeList = [Ref]
  , tuneList = [Base, Peak]
  , iterations = 10
  , configBuilder = build
  }

collectStats :: Bool
collectStats = True

standardGHC :: FilePath
standardGHC = "/Research/darcs/ghc-HEAD.BUILD/inplace/bin"

build :: ConfigBuilder
build ConfigTuneDefault ConfigBenchDefault = do
  setTimeout $ Limit 0 10 0
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
  
  -- Setup stats collection 
  if collectStats 
    then do
    collectExtraStatsFrom  "ghc.stats"
    append RunFlags "+RTS -tghc.stats --machine-readable -RTS"
    else
    done

build (ConfigTune Base) ConfigBenchDefault = do
  append ConfigureFlags "-O2"

build (ConfigTune Peak) ConfigBenchDefault = do
  append ConfigureFlags "-O2"
  append ConfigureFlags "--ghc-option=-fllvm"

build (ConfigTuneDefault) (ConfigBench Cpsa) = do
  append BuildFlags "--ghc-option=-fcontext-stack=42"

build (ConfigTuneDefault) (ConfigBench QuickHull) = do
  append RunFlags "+RTS -K16M -RTS"

build _ _ = done
