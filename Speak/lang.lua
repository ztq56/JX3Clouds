-- config: gbk --

local _t
_t = {
  NAME = "lang",
  -- strings = {},
  L = function(name)
    return _t.strings[name] or name
  end,
}

_t.module = Clouds.Speak
Clouds.Speak.lang = _t
Clouds.Base.base.gen_all_msg(_t)

_t.strings = {
  SkillMon = "���ܺ���",
  SkillSpeakTitle = "���ܺ���",
  Add = "����",
  Save = "����",
  Reset = "����",
  hit = "����",
  got = "������",
  casting = "����",
  SkillName = "������",
  SkillAction = "����",
  Setup = "����",
  SkillSpeakEnabled = "���ܺ�������",
  New = "�½�",
  Modify = "�޸�",
  Delete = "ɾ��",
}