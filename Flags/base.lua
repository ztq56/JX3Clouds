Clouds_Flags = {
  NAME = "Clouds_Flags",
  DEBUG = Clouds_Base.DEBUG,
  LEVEL = Clouds_Base.LEVEL,
  LEVEL_CURRENT = Clouds_Base.LEVEL_CURRENT,
  LEVEL_LOG = Clouds_Base.LEVEL_LOG,
}

local _t
_t = {
  NAME = "base",
  gen_msg = Clouds_Base.module_gen_msg(Clouds_Flags),
  gen_all_msg = Clouds_Base.base.gen_all_msg
}

_t.module = Clouds_Flags
Clouds_Flags.base = _t