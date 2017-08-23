local player
player = {
  NAME = "Clouds_Player",
  DEBUG = true,
  LEVEL = Clouds_Base.LEVEL,
  LEVEL_CURRENT = Clouds_Base.LEVEL.VERBOSE,
  LEVEL_LOG = Clouds_Base.LEVEL.VERBOSEEX,
}
_G.Clouds_Player = player

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Player),
  gen_all_msg = Clouds_Base.base.gen_all_msg
}

_t.module = Clouds_Player
Clouds_Player.base = _t