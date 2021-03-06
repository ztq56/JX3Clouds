
----------------------------------------------
-- EasyUI 界面库
-- Author: crazy
-- SinaWeibo: @南诏大将军
-- CreatData: 2013.9.24
----------------------------------------------

do
	if EasyUI then
		return
	end
end

----------------------------------------------
-- Lua OOP
----------------------------------------------
local _class = {}

local function class(super)
	local class_type = {}
	class_type.ctor = false
	class_type.super = super
	class_type.new = function(...)
		local obj = {}
		setmetatable(obj, { __index = _class[class_type]})
		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c.ctor then
					c.ctor(obj, ...)
				end
			end
			create(class_type, ...)
		end
		return obj
	end
	local vtbl = {}
	_class[class_type] = vtbl

	setmetatable(class_type,{__newindex =
		function(t, k, v)
			vtbl[k] = v
		end
	})

	if super then
		setmetatable(vtbl,{__index =
			function(t, k)
				local ret = _class[super][k]
				vtbl[k] = ret
				return ret
			end
		})
	end

	return class_type
end

local __ini = "Interface/EasyUI/ini/%s.ini"
local NAME_INDEX = 1
----------------------------------------------
-- Wnd Type Controls
----------------------------------------------

local Pos = class()
function Pos:ctor(left, top, space, width)
	self.left = left
	self.top = top
	self.space = space or 5
	self.width = width or -1
	self:Reset()
end

function Pos:Reset(x, y)
	self.x = x or self.left
	self.y = y or self.top
	self.last = 0
end

function Pos:Next(w, h)
	if self.width > 0 and self.x <= self.left and self.x + w > self.width then
		self:NextLine()
	end
	local rect = { x = self.x, y = self.y, w = w, h = h }
	self.x = self.x + w + self.space
	if self.last < h then
		self.last = h
	end
	return rect
end

function Pos:NextLine(space, w, h)
	self.x = self.left
	if space or self.last ~= 0 then
		self.y = self.y + self.last + (space or self.space)
	end
	if w and h then
		return self:Next(w, h)
	end
end

-- Append Control
local _AppendWnd = function(__parent, __type, __name)
	if not __name then
		__name = string.format("EASYUI_INDEX_%d", NAME_INDEX)
		NAME_INDEX = NAME_INDEX + 1
	end
	if __parent.__addon then
		__parent = __parent:GetSelf()
	end
	local rand_name = "EASYUI_" .. math.random()
	local hwnd = Wnd.OpenWindow(string.format(__ini, __type), rand_name):Lookup(__type)
	hwnd:ChangeRelation(__parent, true, true)
	hwnd:SetName(__name)
	Wnd.CloseWindow(rand_name)
	return hwnd
end

-- Base Class of WndType Control
local WndBase = class()
function WndBase:ctor(__this)
	self.__addon = true
	self.__listeners = {self}
end

function WndBase:IsValid()
	return self.__this:IsValid()
end

function WndBase:GetName()
	return self.__this:GetName()
end

function WndBase:_SetSelf(__this)
	self.__this = __this
end

function WndBase:GetSelf()
	return self.__this
end

function WndBase:SetSize(...)
	self.__this:SetSize(...)
	return self
end

function WndBase:GetSize()
	return self.__this:GetSize()
end

function WndBase:SetRelPos(...)
	self.__this:SetRelPos(...)
	return self
end

function WndBase:GetRelPos()
	return self.__this:GetRelPos()
end

function WndBase:SetAbsPos(...)
	self.__this:SetAbsPos(...)
	return self
end

function WndBase:GetAbsPos()
	return self.__this:GetAbsPos()
end

function WndBase:Enable(...)
	self.__this:Enable(...)
	return self
end

function WndBase:_SetParent(__parent)
	self.__parent = __parent
end

function WndBase:GetParent()
	return self.__parent
end

function WndBase:_SetType(__type)
	self.__type = __type
end

function WndBase:GetType()
	return self.__type
end

function WndBase:Destroy()
	local __name = self:GetName()
	if self:GetType() == "WndFrame" then
		Wnd.CloseWindow(__name)
	else
		self.__this:Destroy()
	end
end

function WndBase:Show()
	self.__this:Show()
	return self
end

function WndBase:Hide()
	self.__this:Hide()
	return self
end

function WndBase:IsVisible()
	return self.__this:IsVisible()
end

function WndBase:ToggleVisible()
	self.__this:ToggleVisible()
end

function WndBase:Scale(...)
	self.__this:Scale(...)
	return self
end

function WndBase:CorrectPos(...)
	self.__this:CorrectPos(...)
	return self
end

function WndBase:SetMousePenetrable(...)
	self.__this:SetMousePenetrable(...)
	return self
end

function WndBase:SetAlpha(...)
	self.__this:SetAlpha(...)
	return self
end

function WndBase:GetAlpha()
	return self.__this:GetAlpha()
end

function WndBase:ChangeRelation(...)
	self.__this:ChangeRelation(...)
	return self
end

function WndBase:SetPoint(...)
	self.__this:SetPoint(...)
	return self
end

function WndBase:_FireEvent(__event, ...)
	for __k, __v in pairs(self.__listeners) do
		if __v[__event] then
			local res, err = pcall(__v[__event], ...)
			if not res then
				OutputMessage("MSG_SYS", "ERROR:" .. err .."\n")
			end
		end
	end
end

-- WndFrame Obejct
local WndFrame = class(WndBase)
function WndFrame:ctor(__name, __data)
	assert(__name ~= nil, "frame name can not be null.")
	__data = __data or {}
	local frame = nil
	if __data.style == "THIN" then
		frame = Wnd.OpenWindow(string.format(__ini, "WndFrameThin"), __name)
	elseif __data.style == "SMALL" then
		frame = Wnd.OpenWindow(string.format(__ini, "WndFrameSmall"), __name)
	elseif __data.style == "NORMAL" then
		frame = Wnd.OpenWindow(string.format(__ini, "WndFrame"), __name)
	elseif __data.style == "LARGER" then
		frame = Wnd.OpenWindow(string.format(__ini, "WndFrameLarger"), __name)
	elseif __data.style == "NONE" then
		frame = Wnd.OpenWindow(string.format(__ini, "WndFrameNone"), __name)
	end
	frame:SetName(__name)
	--self:Register(__name)
	self.__this = frame
	self:_SetSelf(self.__this)
	self:_SetType("WndFrame")
	if __data.style and __data.style ~= "NONE" then
		frame:Lookup("Btn_Close").OnLButtonClick = function()
			self:Destroy()
		end
		self:SetTitle(__data.title or "")
	end
end

function WndFrame:GetHandle()
	return self.__this:Lookup("", "")
end

function WndFrame:ClearHandle()
	self.__this:Lookup("", ""):Clear()
	return self
end

function WndFrame:SetTitle(...)
	self.__this:Lookup("", "Text_Title"):SetText(...)
	return self
end

function WndFrame:GetTitle()
	return self.__this:Lookup("", "Text_Title"):GetText()
end

function WndFrame:EnableDrag(...)
	self.__this:EnableDrag(...)
	return self
end

function WndFrame:IsDragable()
	return self.__this:IsDragable()
end

function WndFrame:SetDragArea(...)
	self.__this:SetDragArea(...)
	return self
end

function WndFrame:RegisterEvent(...)
	self.__this:RegisterEvent(...)
	return self
end

function WndFrame:FadeIn(...)
	self.__this:FadeIn(...)
	return self
end

function WndFrame:FadeOut(...)
	self.__this:FadeOut(...)
	return self
end

function WndFrame:IsAddOn()
	return self.__this:IsAddOn()
end

-- WndWindow Object
local WndWindow = class(WndBase)
function WndWindow:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndWindow", __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndWindow")
	self:SetSize(__data.w or 100, __data.h or 100)
	self:SetRelPos(__data.x or 0, __data.y or 0)
end

function WndWindow:SetSize(...)
	self.__this:SetSize(...)
	self.__this:Lookup("", ""):SetSize(...)
	return self
end

function WndWindow:GetHandle()
	return self.__this:Lookup("", "")
end

function WndWindow:ClearHandle()
	self.__this:Lookup("", ""):Clear()
	return self
end

-- WndPageSet Object
local WndPageSet = class(WndBase)
function WndPageSet:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndPageSet", __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndPageSet")
	self:SetSize(__data.w or 100, __data.h or 100)
	self:SetRelPos(__data.x or 0, __data.y or 0)
end

function WndPageSet:AddPage(...)
	self.__this:AddPage(...)
	return self
end

function WndPageSet:GetActivePage()
	return self.__this:GetActivePage()
end

function WndPageSet:GetActiveCheckBox()
	return self.__this:GetActiveCheckBox()
end

function WndPageSet:ActivePage(...)
	self.__this:ActivePage(...)
	return self
end

function WndPageSet:GetActivePageIndex()
	return self.__this:GetActivePageIndex()
end

function WndPageSet:GetLastActivePageIndex()
	return self.__this:GetLastActivePageIndex()
end

-- WndButton Object
local WndButton = class(WndBase)
function WndButton:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndButton", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndButton")
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetSize(__data.w or 91)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	--Bind Button Events
	self.__this.OnLButtonClick = function()
		self:_FireEvent("OnClick")
	end
	self.__this.OnMouseEnter = function()
		self:_FireEvent("OnEnter")
	end
	self.__this.OnMouseLeave = function()
		self:_FireEvent("OnLeave")
	end
end

function WndButton:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__this:Enable(true)
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__this:Enable(false)
	end
	return self
end

function WndButton:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndButton:GetText()
	return self.__text:GetText()
end

function WndButton:IsEnabled()
	return self.__this:IsEnabled()
end

function WndButton:SetSize(__w)
	self.__this:SetSize(__w, 26)
	self.__this:Lookup("", ""):SetSize(__w, 26)
	self.__text:SetSize(__w, 26)
	return self
end

-- WndUIButton Object
local WndUIButton = class(WndBase)
function WndUIButton:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndUIButton", __name)
	self.__image = hwnd:Lookup("", "Image_Default")
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__text:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndUIButton")
	self.__animate = __data.ani
	self:SetSize(__data.w or 40, __data.h or 40)
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetRelPos(__data.x or 0, __data.y or 0)
	self:_UpdateNormal()

	--Bind Button Events
	self.__this.OnMouseEnter = function()
		if self:IsEnabled() then
			self:_UpdateOver()
		end
		self:_FireEvent("OnEnter")
	end
	self.__this.OnMouseLeave = function()
		if self:IsEnabled() then
			self:_UpdateNormal()
		end
		self:_FireEvent("OnLeave")
	end
	self.__this.OnLButtonClick = function()
		self:_FireEvent("OnClick")
	end
	self.__this.OnLButtonDown = function()
		if self:IsEnabled() then
			self:_UpdateDown()
		end
	end
	self.__this.OnLButtonUp = function()
		if self:IsEnabled() then
			self:_UpdateOver()
		end
	end
	self.__this.OnRButtonDown = function()
		if self:IsEnabled() then
			self:_UpdateDown()
		end
	end
	self.__this.OnRButtonUp = function()
		if self:IsEnabled() then
			self:_UpdateOver()
		end
	end
end

function WndUIButton:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__this:Enable(true)
		self:_UpdateNormal()
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__this:Enable(false)
		self:_UpdateDisable()
	end
	return self
end

function WndUIButton:_UpdateNormal()
	self.__image:FromUITex(self.__animate[1], self.__animate[2])
end

function WndUIButton:_UpdateOver()
	self.__image:FromUITex(self.__animate[1], self.__animate[3])
end

function WndUIButton:_UpdateDown()
	self.__image:FromUITex(self.__animate[1], self.__animate[4])
end

function WndUIButton:_UpdateDisable()
	self.__image:FromUITex(self.__animate[1], self.__animate[5])
end

function WndUIButton:IsEnabled()
	return self.__this:IsEnabled()
end

function WndUIButton:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndUIButton:GetText()
	return self.__text:GetText()
end

function WndUIButton:SetSize(__w, __h)
	self.__this:SetSize(__w, __h)
	self.__this:Lookup("", ""):SetSize(__w, __h)
	self.__image:SetSize(__w, __h)
	self.__text:SetSize(__w, __h)
	return self
end

-- WndEdit Object
local WndEdit = class(WndBase)
function WndEdit:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndEdit", __name)
	self.__edit = hwnd:Lookup("Edit_Default")
	self:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndEdit")
	self:SetLimit(__data.limit or 36)
	self:SetMultiLine(__data.multi or false)
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetSize(__data.w or 187, __data.h or 25)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	--Bind Edit Events
	self.__edit.OnEditChanged = function()
		local __text = self.__edit:GetText()
		self:_FireEvent("OnChange", __text)
	end
	self.__edit.OnSetFocus = function()
		self:_FireEvent("OnSetFocus")
	end
	self.__edit.OnKillFocus = function()
		self:_FireEvent("OnKillFocus")
	end
end

function WndEdit:SetSize(__w, __h)
	self.__this:SetSize(__w + 4, __h)
	self.__this:Lookup("", ""):SetSize(__w + 4, __h)
	self.__this:Lookup("", "Image_Default"):SetSize(__w + 4, __h)
	self.__edit:SetSize(__w, __h)
	return self
end

function WndEdit:SetLimit(...)
	self.__edit:SetLimit(...)
	return self
end

function WndEdit:SetMultiLine(...)
	self.__edit:SetMultiLine(...)
	return self
end

function WndEdit:Enable(__enable)
	if __enable then
		self.__edit:SetFontColor(255, 255, 255)
		self.__edit:Enable(true)
	else
		self.__edit:SetFontColor(180, 180, 180)
		self.__edit:Enable(false)
	end
	return self
end

function WndEdit:SelectAll()
	self.__this:SelectAll()
	return self
end

function WndEdit:SetText(...)
	self.__edit:SetText(...)
	return self
end

function WndEdit:GetText()
	return self.__edit:GetText()
end

function WndEdit:ClearText()
	self.__edit:ClearText()
	return self
end

function WndEdit:SetType(...)
	self.__edit:SetType(...)
	return self
end

function WndEdit:SetFontScheme(...)
	self.__edit:SetFontScheme(...)
	return self
end

function WndEdit:SetFontColor(...)
	self.__edit:SetFontColor(...)
	return self
end

function WndEdit:SetSelectFontScheme(...)
	self.__edit:SetSelectFontScheme(...)
	return self
end

-- WndCheckBox Object
local WndCheckBox = class(WndBase)
function WndCheckBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndCheckBox", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__text:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndCheckBox")
	self:Check(__data.check or false)
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetSize(__data.w or 150)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	--Bind CheckBox Events
	self.__this.OnCheckBoxCheck = function()
		self:_FireEvent("OnCheck", true)
	end
	self.__this.OnCheckBoxUncheck = function()
		self:_FireEvent("OnCheck", false)
	end
end

function WndCheckBox:SetSize(__w)
	self.__text:SetSize(__w - 28, 25)
	return self
end

function WndCheckBox:Check(...)
	self.__this:Check(...)
	return self
end

function WndCheckBox:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__this:Enable(true)
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__this:Enable(false)
	end
	return self
end

function WndCheckBox:IsChecked()
	return self.__this:IsCheckBoxChecked()
end

function WndCheckBox:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndCheckBox:GetText()
	return self.__text:GetText()
end

function WndCheckBox:SetFontColor(...)
	self.__text:SetFontColor(...)
	return self
end

function WndCheckBox:GetFontColor()
	return self.__text:GetFontColor()
end

function WndCheckBox:SetFontScheme(...)
	self.__text:SetFontScheme(...)
	return self
end

function WndCheckBox:GetFontScheme()
	return self.__text:GetFontScheme()
end

-- WndComboBox Object
local WndComboBox = class(WndBase)
function WndComboBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndComboBox", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__text:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndComboBox")
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetSize(__data.w or 185)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	--Bind ComboBox Events
	self.__this:Lookup("Btn_ComboBox").OnLButtonClick = function()
		local __x, __y = self:GetAbsPos()
		local __w, __h = self:GetSize()
		local __menu = {}
		__menu.nMiniWidth = __w
		__menu.x = __x
		__menu.y = __y + __h
		self:_FireEvent("OnClick", __menu)
	end
end

function WndComboBox:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__this:Lookup("Btn_ComboBox"):Enable(true)
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__this:Lookup("Btn_ComboBox"):Enable(false)
	end
	return self
end

function WndComboBox:SetSize(__w)
	self.__this:SetSize(__w, 25)
	local handle = self.__this:Lookup("", "")
	handle:SetSize(__w, 25)
	handle:Lookup("Image_ComboBoxBg"):SetSize(__w,25)
	handle:Lookup("Text_Default"):SetSize(__w - 20, 25)
	local btn = self.__this:Lookup("Btn_ComboBox")
	btn:SetRelPos(__w - 25, 3)
	local h = btn:Lookup("", "")
	h:SetSize(__w, 25)
	local __x, __y = handle:GetAbsPos()
	h:SetAbsPos(__x, __y)
	return self
end

function WndComboBox:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndComboBox:GetText()
	return self.__text:GetText()
end

-- WndRadioBox Object
local WndRadioBox = class(WndBase)
function WndRadioBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndRadioBox", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__text:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndRadioBox")
	self:Check(__data.check or false)
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetSize(__data.w or 150)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	self.__this.__group = __data.group
	self:SetGroup(__data.group)

	--Bind RadioBox Events
	self.__this.OnCheckBoxCheck = function()
		if self.__group then
			for k, v in pairs(self.__parent.groups[self.__group]) do
				if v:IsValid() and v:GetGroup() == self.__group and v:GetName() ~= self:GetName() then
					v:Check(false)
				end
			end
			self:_FireEvent("OnCheck", true)
		end
	end
end

function WndRadioBox:SetSize(__w)
	self.__text:SetSize(__w - 28, 25)
	return self
end

function WndRadioBox:SetGroup(__group)
	if __group then
		if not self.__parent.groups then
			self.__parent.groups = {}
		end
		if not self.__parent.groups[__group] then
			self.__parent.groups[__group] = {}
		end
		table.insert(self.__parent.groups[__group], self)
	end
	self.__group = __group
	return self
end

function WndRadioBox:GetGroup()
	return self.__group
end

function WndRadioBox:IsChecked()
	return self.__this:IsCheckBoxChecked()
end

function WndRadioBox:Check(...)
	self.__this:Check(...)
	return self
end

function WndRadioBox:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__this:Enable(true)
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__this:Enable(false)
	end
	return self
end

function WndRadioBox:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndRadioBox:GetText()
	return self.__text:GetText()
end

function WndRadioBox:SetFontColor(...)
	self.__text:SetFontColor(...)
	return self
end

function WndRadioBox:GetFontColor()
	return self.__text:GetFontColor()
end

function WndRadioBox:SetFontScheme(...)
	self.__text:SetFontScheme(...)
	return self
end

function WndRadioBox:GetFontScheme()
	return self.__text:GetFontScheme()
end

-- WndUICheckBox Object
local WndUICheckBox = class(WndBase)
function WndUICheckBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndUICheckBox", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self:SetText(__data.text or "")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndUICheckBox")
	self:Check(__data.check or false)
	self:SetSize(__data.w or 83, __data.h or 30)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	self.__this.__group = __data.group
	self:SetGroup(__data.group)

	--Bind UICheckBox Events
	self.__this.OnCheckBoxCheck = function()
		if self.__group then
			for k, v in pairs(self.__parent.groups[self.__group]) do
				if v:IsValid() and v:GetGroup() == self.__group and v:GetName() ~= self:GetName() then
					v:Check(false)
				end
			end
		end
		self:_FireEvent("OnCheck", true)
	end
end

function WndUICheckBox:SetGroup(__group)
	if __group then
		if not self.__parent.groups then
			self.__parent.groups = {}
		end
		if not self.__parent.groups[__group] then
			self.__parent.groups[__group] = {}
		end
		table.insert(self.__parent.groups[__group], self)
	end
	self.__group = __group
	return self
end

function WndUICheckBox:GetGroup()
	return self.__group
end

function WndUICheckBox:Check(...)
	self.__this:Check(...)
	return self
end

function WndUICheckBox:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndUICheckBox:SetAnimation(...)
	self.__this:SetAnimation(...)
	return self
end

function WndUICheckBox:SetSize(...)
	self.__this:SetSize(...)
	self.__this:Lookup("", ""):SetSize(...)
	self.__text:SetSize(...)
	return self
end

-- WndCSlider Object
local WndCSlider = class(WndBase)
function WndCSlider:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndCSlider", __name)
	self.__scroll = hwnd:Lookup("Scroll_Default")
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndCSlider")
	self.__min = __data.min
	self.__max = __data.max
	self.__step = __data.step
	self.__unit = __data.unit or ""
	self.__scroll:SetStepCount(__data.step)
	self:SetSize(__data.w or 120)
	self:Enable((__data.enable == nil or __data.enable) and true or false)
	self:SetRelPos(__data.x or 0, __data.y or 0)
	self:UpdateScrollPos(__data.value or 0)

	--Bind CSlider Events
	self.__scroll.OnScrollBarPosChanged = function()
		local __step = this:GetScrollPos()
		local __value = self:GetValue(__step)
		self.__text:SetText(__value .. self.__unit)
		self:_FireEvent("OnChange", __value)
	end
end

function WndCSlider:Enable(__enable)
	if __enable then
		self.__text:SetFontColor(255, 255, 255)
		self.__scroll:Enable(true)
	else
		self.__text:SetFontColor(180, 180, 180)
		self.__scroll:Enable(false)
	end
	return self
end

function WndCSlider:SetSize(__w)
	self.__this:SetSize(__w, 25)
	self.__this:Lookup("", ""):SetSize(__w, 25)
	self.__this:Lookup("", ""):Lookup("Image_BG"):SetSize(__w, 10)
	self.__scroll:SetSize(__w, 25)
	self.__text:SetRelPos(__w + 5, 2)
	self.__this:Lookup("", ""):FormatAllItemPos()
	return self
end

function WndCSlider:GetValue(__step)
	return self.__min + __step * (self.__max - self.__min) / self.__step
end

function WndCSlider:GetStep(__value)
	return (__value - self.__min) * self.__step / (self.__max - self.__min)
end

function WndCSlider:ChangeToArea(__min, __max, __step)
	return __min + (__max - __min) * (self:GetValue(__step) - self.__min) / (self.__max - self.__min)
end

function WndCSlider:ChangeToAreaFromValue(__min, __max, __value)
	return __min + (__max - __min) * (__value - self.__min) / (self.__max - self.__min)
end

function WndCSlider:GetStepFromArea(__min, __max, __value)
	return self:GetStep(self.__min + (self.__max - self.__min) * (__value - __min) / (__max - __min))
end

function WndCSlider:UpdateScrollPos(__value)
	self.__text:SetText(__value .. self.__unit)
	self.__scroll:SetScrollPos(self:GetStep(__value))
	return self
end

-- WndColorBox Object
local WndColorBox = class(WndBase)
function WndColorBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndColorBox", __name)
	self.__text = hwnd:Lookup("", "Text_Default")
	self.__shadow = hwnd:Lookup("", "Shadow_Default")
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndColorBox")
	self.__r = __data.r
	self.__g = __data.g
	self.__b = __data.b
	self:SetText(__data.text)
	self:SetColor(__data.r, __data.g, __data.b)
	self:SetSize(__data.w or 140)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	--Bind ColorBox Events
	self.__shadow.OnItemLButtonClick = function()
		local fnChangeColor = function(r, g, b)
			self:SetColor(r, g, b)
			self:_FireEvent("OnChange", {r, g, b})
		end
		OpenColorTablePanel(fnChangeColor)
	end
end

function WndColorBox:SetSize(__w)
	self.__this:SetSize(__w, 25)
	self.__this:Lookup("", ""):SetSize(__w, 25)
	self.__text:SetSize(__w - 25, 25)
	return self
end

function WndColorBox:SetText(...)
	self.__text:SetText(...)
	return self
end

function WndColorBox:SetColor(...)
	self.__shadow:SetColorRGB(...)
	self.__text:SetFontColor(...)
	return self
end

-- WndScroll Object
local WndScroll = class(WndBase)
function WndScroll:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local hwnd = _AppendWnd(__parent, "WndScroll", __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:_SetType("WndScroll")
	self.__up = self.__this:Lookup("Btn_Up")
	self.__down = self.__this:Lookup("Btn_Down")
	self.__scroll = self.__this:Lookup("Scroll_List")
	self.__handle = self.__this:Lookup("", "")

	self:SetSize(__data.w or 500, __data.h or 345)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	self.__up.OnLButtonHold = function()
		self.__scroll:ScrollPrev(1)
	end
	self.__up.OnLButtonDown = function()
		self.__scroll:ScrollPrev(1)
	end
	self.__down.OnLButtonHold = function()
		self.__scroll:ScrollNext(1)
	end
	self.__down.OnLButtonDown = function()
		self.__scroll:ScrollNext(1)
	end
	self.__handle.OnItemMouseWheel = function()
		local __dist = Station.GetMessageWheelDelta()
		self.__scroll:ScrollNext(__dist)
		return true
	end
	self.__scroll.OnScrollBarPosChanged = function()
		local __value = this:GetScrollPos()
		if __value == 0 then
			self.__up:Enable(false)
		else
			self.__up:Enable(true)
		end
		if __value == this:GetStepCount() then
			self.__down:Enable(false)
		else
			self.__down:Enable(true)
		end
		self.__handle:SetItemStartRelPos(0, -__value * 10)
	end
end

function WndScroll:GetHandle()
	return self.__handle
end

function WndScroll:AddItem(__name)
	assert(false, "do not use this api")
	local __item = nil
	return __item
end

function WndScroll:SetHandleStyle(...)
	self.__handle:SetHandleStyle(...)
	return self
end

function WndScroll:ClearHandle()
	self.__handle:Clear()
	return self
end

function WndScroll:ScrollPagePrev()
	self.__scroll:ScrollPagePrev()
	return self
end

function WndScroll:ScrollPageNext()
	self.__scroll:ScrollPageNext()
	return self
end

function WndScroll:ScrollHome()
	self.__scroll:ScrollHome()
	return self
end

function WndScroll:ScrollEnd()
	self.__scroll:ScrollEnd()
	return self
end

function WndScroll:UpdateList()
	self.__handle:FormatAllItemPos()
	local __w, __h = self.__handle:GetSize()
	local __wAll, __hAll = self.__handle:GetAllItemSize()
	local __count = math.ceil((__hAll - __h) / 10)

	self.__scroll:SetStepCount(__count)
	if __count > 0 then
		self.__scroll:Show()
		self.__up:Show()
		self.__down:Show()
	else
		self.__scroll:Hide()
		self.__up:Hide()
		self.__down:Hide()
	end
end

function WndScroll:SetSize(__w, __h)
	self.__this:SetSize(__w, __h)
	self.__handle:SetSize(__w, __h)
	self.__scroll:SetSize(15, __h - 40)
	self.__scroll:SetRelPos(__w - 17, 20)
	self.__up:SetRelPos(__w - 20, 3)
	self.__down:SetRelPos(__w - 20, __h - 20)
	return self
end

----------------------------------------------
-- ItemNull Type Controls
----------------------------------------------

-- Append Control
local _AppendItem = function(__parent, __string, __name)
	if not __name then
		__name = string.format("EASYUI_INDEX_%d", NAME_INDEX)
		NAME_INDEX = NAME_INDEX + 1
	end
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	local __count = __parent:GetItemCount()
	__parent:AppendItemFromString(__string)
	local hwnd = __parent:Lookup(__count)
	hwnd:SetName(__name)
	return hwnd
end

-- Base Class of ItemType Control
local ItemBase = class()
function ItemBase:ctor(__this)
	self.__addon = true
	self.__listeners = {self}
end

function ItemBase:SetName(...)
	self.__this:SetName(...)
	return self
end

function ItemBase:GetName()
	return self.__this:GetName()
end

function ItemBase:Scale(...)
	self.__this:Scale(...)
	return self
end

function ItemBase:LockShowAndHide(...)
	self.__this:LockShowAndHide(...)
	return self
end

function ItemBase:_SetSelf(__this)
	self.__this = __this
end

function ItemBase:GetSelf()
	return self.__this
end

function ItemBase:SetSize(...)
	self.__this:SetSize(...)
	return self
end

function ItemBase:GetSize()
	return self.__this:GetSize()
end

function ItemBase:SetRelPos(...)
	self.__this:SetRelPos(...)
	return self
end

function ItemBase:GetRelPos()
	return self.__this:GetRelPos()
end

function ItemBase:SetAbsPos(...)
	self.__this:SetAbsPos(...)
	return self
end

function ItemBase:GetAbsPos()
	return self.__this:GetAbsPos()
end

function ItemBase:SetAlpha(...)
	self.__this:SetAlpha(...)
	return self
end

function ItemBase:SetTip(...)
	self.__this:SetTip(...)
	return self
end

function ItemBase:GetTip()
	return self.__this:GetTip()
end

function ItemBase:GetAlpha()
	return self.__this:GetAlpha()
end

function ItemBase:GetType()
	return self.__this:GetType()
end

function ItemBase:SetPosType(...)
	self.__this:SetPosType(...)
	return self
end

function ItemBase:GetPosType()
	return self.__this:GetPosType()
end

function ItemBase:_SetParent(__parent)
	self.__parent = __parent
end

function ItemBase:GetParent()
	return self.__parent
end

function ItemBase:Destroy()
	self.__parent:RemoveItem(self.__this)
end

function ItemBase:Show()
	self.__this:Show()
	return self
end

function ItemBase:Hide()
	self.__this:Hide()
	return self
end

function ItemBase:IsVisible()
	return self.__this:IsVisible()
end

function ItemBase:_FireEvent(__event, ...)
	for __k, __v in pairs(self.__listeners) do
		if __v[__event] then
			local res, err = pcall(__v[__event],  ...)
			if not res then
				OutputMessage("MSG_SYS", "ERROR:" .. err .. "\n")
			end
		end
	end
end

-- Handle Object
local ItemHandle = class(ItemBase)
function ItemHandle:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<handle>w=10 h=10 handletype=0 postype=0 eventid=272 </handle>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.handletype then
		__string = string.gsub(__string, "handletype=%d+", string.format("handletype=%d", __data.handletype))
	end
	--[[if __data.firstpostype then
		__string = string.gsub(__string, "firstpostype=%d+", string.format("firstpostype=%d", __data.firstpostype))
	end]]
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	--Output(__string)
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:SetRelPos(__data.x or 0, __data.y or 0)

	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()

	--Bind Handle Events
	self.__this.OnItemLButtonClick = function()
		self:_FireEvent("OnClick")
	end
	self.__this.OnItemMouseEnter = function()
		self:_FireEvent("OnEnter")
	end
	self.__this.OnItemMouseLeave = function()
		self:_FireEvent("OnLeave")
	end
end

function ItemHandle:GetHandle()
	return self.__this
end

function ItemHandle:FormatAllItemPos()
	self.__this:FormatAllItemPos()
	return self
end

function ItemHandle:SetHandleStyle(...)
	self.__this:SetHandleStyle(...)
	return self
end

function ItemHandle:GetItemStartRelPos()
	return self.__this:GetItemStartRelPos()
end

function ItemHandle:SetItemStartRelPos(...)
	self.__this:SetItemStartRelPos(...)
	return self
end

function ItemHandle:SetSizeByAllItemSize()
	self.__this:SetSizeByAllItemSize()
	return self
end

function ItemHandle:GetAllItemSize()
	return self.__this:GetAllItemSize()
end

function ItemHandle:GetVisibleItemCount()
	return self.__this:GetVisibleItemCount()
end

function ItemHandle:EnableFormatWhenAppend(...)
	self.__this:EnableFormatWhenAppend(...)
	return self
end

function ItemHandle:ExchangeItemIndex(...)
	self.__this:ExchangeItemIndex(...)
	return self
end

function ItemHandle:Sort()
	self.__this:Sort()
	return self
end

function ItemHandle:GetItemCount()
	return self.__this:GetItemCount()
end

function ItemHandle:ClearHandle()
	self.__this:Clear()
	return self
end

-- Text Object
local ItemText = class(ItemBase)
function ItemText:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<text>w=150 h=30 valign=1 font=162 postype=0 </text>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.valign then
		__string = string.gsub(__string, "valign=%d+", string.format("valign=%d", __data.valign))
	end
	if __data.font then
		__string = string.gsub(__string, "font=%d+", string.format("font=%d", __data.font))
	end
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:SetText(__data.text or "")
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()
end

function ItemText:SetText(...)
	self.__this:SetText(...)
	return self
end

function ItemText:GetText()
	return self.__this:GetText()
end

function ItemText:SetFontScheme(...)
	self.__this:SetFontScheme(...)
	return self
end

function ItemText:GetFontScheme()
	return self.__this:GetFontScheme()
end

function ItemText:GetTextLen()
	return self.__this:GetTextLen()
end

function ItemText:SetVAlign(...)
	self.__this:SetVAlign(...)
	return self
end

function ItemText:GetVAlign()
	return self.__this:GetVAlign()
end

function ItemText:SetHAlign(...)
	self.__this:SetHAlign(...)
	return self
end

function ItemText:GetHAlign()
	return self.__this:GetHAlign()
end

function ItemText:SetRowSpacing(...)
	self.__this:SetRowSpacing(...)
	return self
end

function ItemText:GetRowSpacing()
	return self.__this:GetRowSpacing()
end

function ItemText:SetMultiLine(...)
	self.__this:SetMultiLine(...)
	return self
end

function ItemText:IsMultiLine()
	return self.__this:IsMultiLine()
end

function ItemText:FormatTextForDraw(...)
	self.__this:FormatTextForDraw(...)
	return self
end

function ItemText:AutoSize()
	self.__this:AutoSize()
	return self
end

function ItemText:SetCenterEachLine(...)
	self.__this:SetCenterEachLine(...)
	return self
end

function ItemText:IsCenterEachLine()
	return self.__this:IsCenterEachLine()
end

function ItemText:SetRichText(...)
	self.__this:SetRichText(...)
	return self
end

function ItemText:IsRichText()
	return self.__this:IsRichText()
end

function ItemText:GetFontScale()
	return self.__this:GetFontScale()
end

function ItemText:SetFontScale(...)
	self.__this:SetFontScale(...)
	return self
end

function ItemText:SetFontID(...)
	self.__this:SetFontID(...)
	return self
end

function ItemText:SetFontBorder(...)
	self.__this:SetFontBorder(...)
	return self
end

function ItemText:SetFontShadow(...)
	self.__this:SetFontShadow(...)
	return self
end

function ItemText:GetFontID()
	return self.__this:GetFontID()
end

function ItemText:GetFontBoder()
	return self.__this:GetFontBoder()
end

function ItemText:GetFontProjection()
	return self.__this:GetFontProjection()
end

function ItemText:GetTextExtent()
	return self.__this:GetTextExtent()
end

function ItemText:GetTextPosExtent()
	return self.__this:GetTextPosExtent()
end

function ItemText:SetFontColor(...)
	self.__this:SetFontColor(...)
	return self
end

function ItemText:GetFontColor()
	return self.__this:GetFontColor()
end

function ItemText:SetFontSpacing(...)
	self.__this:SetFontSpacing(...)
	return self
end

function ItemText:GetFontSpacing()
	return self.__this:GetFontSpacing()
end

-- Box Object
local ItemBox = class(ItemBase)
function ItemBox:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<box>w=48 h=48 postype=0 eventid=272 </box>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()

	--Bind Box Events
	self.__this.OnItemMouseEnter = function()
		self:_FireEvent("OnEnter")
	end
	self.__this.OnItemMouseLeave = function()
		self:_FireEvent("OnLeave")
	end
	self.__this.OnItemLButtonClick = function()
		self:_FireEvent("OnClick")
	end
end

function ItemBox:SetObject(...)
	self.__this:SetObject(...)
	return self
end

function ItemBox:GetObject()
	return self.__this:GetObject()
end

function ItemBox:GetObjectType()
	return self.__this:GetObjectType()
end

function ItemBox:GetObjectData()
	return self.__this:GetObjectData()
end

function ItemBox:ClearObject()
	return self.__this:ClearObject()
end

function ItemBox:IsEmpty()
	return self.__this:IsEmpty()
end

function ItemBox:EnableObject(...)
	self.__this:EnableObject(...)
	return self
end

function ItemBox:IsObjectEnable()
	return self.__this:IsObjectEnable()
end

function ItemBox:SetObjectCoolDown(...)
	self.__this:SetObjectCoolDown(...)
	return self
end

function ItemBox:IsObjectCoolDown()
	return self.__this:IsObjectCoolDown()
end

function ItemBox:SetObjectSparking(...)
	self.__this:SetObjectSparking(...)
	return self
end

function ItemBox:SetObjectInUse(...)
	self.__this:SetObjectInUse(...)
	return self
end

function ItemBox:SetObjectStaring(...)
	self.__this:SetObjectStaring(...)
	return self
end

function ItemBox:SetObjectSelected(...)
	self.__this:SetObjectSelected(...)
	return self
end

function ItemBox:IsObjectSelected()
	return self.__this:IsObjectSelected()
end

function ItemBox:SetObjectMouseOver(...)
	self.__this:SetObjectMouseOver(...)
	return self
end

function ItemBox:IsObjectMouseOver()
	return self.__this:IsObjectMouseOver()
end

function ItemBox:SetObjectPressed(...)
	self.__this:SetObjectPressed(...)
	return self
end

function ItemBox:IsObjectPressed()
	return self.__this:IsObjectPressed()
end

function ItemBox:SetCoolDownPercentage(...)
	self.__this:SetCoolDownPercentage(...)
	return self
end

function ItemBox:GetCoolDownPercentage()
	return self.__this:GetCoolDownPercentage()
end

function ItemBox:SetObjectIcon(...)
	self.__this:SetObjectIcon(...)
	return self
end

function ItemBox:GetObjectIcon()
	return self.__this:GetObjectIcon()
end

function ItemBox:ClearObjectIcon()
	self.__this:ClearObjectIcon()
	return self
end

function ItemBox:SetOverText(...)
	self.__this:SetOverText(...)
	return self
end

function ItemBox:GetOverText()
	return self.__this:GetOverText()
end

function ItemBox:SetOverTextFontScheme(...)
	self.__this:SetOverTextFontScheme(...)
	return self
end

function ItemBox:GetOverTextFontScheme()
	return self.__this:GetOverTextFontScheme()
end

function ItemBox:SetOverTextPosition(...)
	self.__this:SetOverTextPosition(...)
	return self
end

function ItemBox:GetOverTextPosition()
	return self.__this:GetOverTextPosition()
end

function ItemBox:SetExtentImage(...)
	self.__this:SetExtentImage(...)
	return self
end

function ItemBox:ClearExtentImage()
	self.__this:ClearExtentImage()
	return self
end

function ItemBox:SetExtentAnimate(...)
	self.__this:SetExtentAnimate(...)
	return self
end

function ItemBox:ClearExtentAnimate()
	self.__this:ClearExtentAnimate()
	return self
end

-- Image Object
local ItemImage = class(ItemBase)
function ItemImage:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<image>w=100 h=100 postype=0 lockshowhide=0 eventid=0 </image>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	if __data.lockshowhide then
		__string = string.gsub(__string, "lockshowhide=%d+", string.format("lockshowhide=%d", __data.lockshowhide))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	if __data.image then
		local __image = __data.image
		local __frame = __data.frame or nil
		self:SetImage(__image, __frame)
	end
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()

	--Bind Image Events
	self.__this.OnItemMouseEnter = function()
		self:_FireEvent("OnEnter")
	end
	self.__this.OnItemMouseLeave = function()
		self:_FireEvent("OnLeave")
	end
	self.__this.OnItemLButtonClick = function()
		self:_FireEvent("OnClick")
	end
end

function ItemImage:SetFrame(...)
	self.__this:SetFrame(...)
	return self
end

function ItemImage:GetFrame()
	return self.__this:GetFrame()
end

function ItemImage:SetImageType(...)
	self.__this:SetImageType(...)
	return self
end

function ItemImage:GetImageType()
	return self.__this:GetImageType()
end

function ItemImage:SetPercentage(...)
	self.__this:SetPercentage(...)
	return self
end

function ItemImage:GetPercentage()
	return self.__this:GetPercentage()
end

function ItemImage:SetRotate(...)
	self.__this:SetRotate(...)
	return self
end

function ItemImage:GetRotate()
	return self.__this:GetRotate()
end

function ItemImage:GetImageID()
	return self.__this:GetImageID()
end

function ItemImage:FromUITex(...)
	self.__this:FromUITex(...)
	return self
end

function ItemImage:FromTextureFile(...)
	self.__this:FromTextureFile(...)
	return self
end

function ItemImage:FromScene(...)
	self.__this:FromScene(...)
	return self
end

function ItemImage:FromImageID(...)
	self.__this:FromImageID(...)
	return self
end

function ItemImage:FromIconID(...)
	self.__this:FromIconID(...)
	return self
end

function ItemImage:SetImage(__image, __frame)
	if type(__image) == "string" then
		if __frame then
			self:FromUITex(__image, __frame)
		else
			self:FromTextureFile(__image)
		end
	elseif type(__image) == "number" then
		self:FromIconID(__image)
	end
	return self
end

-- Shadow Object
local ItemShadow = class(ItemBase)
function ItemShadow:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<shadow>w=15 h=15 postype=0 eventid=277 </shadow>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()
end

function ItemShadow:SetShadowColor(...)
	self.__this:SetShadowColor(...)
	return self
end

function ItemShadow:GetShadowColor()
	return self.__this:GetShadowColor()
end

function ItemShadow:SetColorRGB(...)
	self.__this:SetColorRGB(...)
	return self
end

function ItemShadow:GetColorRGB()
	return self.__this:GetColorRGB()
end

function ItemShadow:SetTriangleFan(...)
	self.__this:SetTriangleFan(...)
	return self
end

function ItemShadow:IsTriangleFan()
	return self.__this:IsTriangleFan()
end

function ItemShadow:AppendTriangleFanPoint(...)
	self.__this:AppendTriangleFanPoint(...)
	return self
end

function ItemShadow:SetD3DPT(...)
	self.__this:SetD3DPT(...)
	return self
end

function ItemShadow:AppendTriangleFan3DPoint(...)
	self.__this:AppendTriangleFan3DPoint(...)
	return self
end

function ItemShadow:ClearTriangleFanPoint()
	self.__this:ClearTriangleFanPoint()
end

function ItemShadow:AppendDoodadID(...)
	self.__this:AppendDoodadID(...)
	return self
end

function ItemShadow:AppendCharacterID(...)
	self.__this:AppendCharacterID(...)
	return self
end

-- ItemAnimate Object
local ItemAnimate = class(ItemBase)
function ItemAnimate:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<animate>w=30 h=30 postype=0 eventid=0 </animate>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.postype then
		__string = string.gsub(__string, "postype=%d+", string.format("postype=%d", __data.postype))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	if __data.image then
		local __image = __data.image
		local __group = __data.group or 0
		local __loop = __data.loop or -1
		self:SetAnimate(__image, __group, __loop)
	end
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()

	--Bind Animate Events
	self.__this.OnItemMouseEnter = function()
		self:_FireEvent("OnEnter")
	end
	self.__this.OnItemMouseLeave = function()
		self:_FireEvent("OnLeave")
	end
	self.__this.OnItemLButtonClick = function()
		self:_FireEvent("OnClick")
	end
end

function ItemAnimate:SetGroup(...)
	self.__this:SetGroup(...)
	return self
end

function ItemAnimate:SetLoopCount(...)
	self.__this:SetLoopCount(...)
	return self
end

function ItemAnimate:SetImagePath(...)
	self.__this:SetImagePath(...)
	return self
end

function ItemAnimate:SetAnimate(...)
	self.__this:SetAnimate(...)
	return self
end

function ItemAnimate:AutoSize()
	self.__this:AutoSize()
	return self
end

function ItemAnimate:Replay()
	self.__this:Replay()
	return self
end

function ItemAnimate:SetIdenticalInterval(...)
	self.__this:SetIdenticalInterval(...)
	return self
end

function ItemAnimate:IsFinished()
	return self.__this:IsFinished()
end

function ItemAnimate:SetAnimateType(...)
	self.__this:SetAnimateType(...)
	return self
end

function ItemAnimate:GetAnimateType()
	return self.__this:GetAnimateType()
end

-- TreeLeaf Object
local ItemTreeLeaf = class(ItemBase)
function ItemTreeLeaf:ctor(__parent, __name, __data)
	assert(__parent ~= nil, "parent can not be null.")
	__data = __data or {}
	local __string = "<treeleaf>w=150 h=25 indentwidth=20 alwaysnode=1 indent=0 eventid=257 </treeleaf>"
	if __data.w then
		__string = string.gsub(__string, "w=%d+", string.format("w=%d", __data.w))
	end
	if __data.h then
		__string = string.gsub(__string, "h=%d+", string.format("h=%d", __data.h))
	end
	if __data.eventid then
		__string = string.gsub(__string, "eventid=%d+", string.format("eventid=%d", __data.eventid))
	end
	local hwnd = _AppendItem(__parent, __string, __name)
	self.__this = hwnd
	self:_SetSelf(self.__this)
	self:_SetParent(__parent)
	self:SetRelPos(__data.x or 0, __data.y or 0)
	if __parent.__addon then
		__parent = __parent:GetHandle()
	end
	__parent:FormatAllItemPos()

	--Bind TreeLeaf Event
	self.__this.OnItemLButtonDown =function()
		self:_FireEvent("OnClick")
	end
end

function ItemTreeLeaf:GetHandle(...)
	return self.__this
end

function ItemTreeLeaf:FormatAllItemPos()
	self.__this:FormatAllItemPos()
	return self
end

function ItemTreeLeaf:SetHandleStyle(...)
	self.__this:SetHandleStyle(...)
	return self
end

function ItemTreeLeaf:SetRowHeight(...)
	self.__this:SetRowHeight(...)
	return self
end

function ItemTreeLeaf:SetRowSpacing(...)
	self.__this:SetRowSpacing(...)
	return self
end

function ItemTreeLeaf:ClearHandle()
	self.__this:Clear()
	return self
end

function ItemTreeLeaf:GetItemStartRelPos()
	return self.__this:GetItemStartRelPos()
end

function ItemTreeLeaf:SetItemStartRelPos(...)
	self.__this:SetItemStartRelPos(...)
	return self
end

function ItemTreeLeaf:SetSizeByAllItemSize()
	self.__this:SetSizeByAllItemSize()
	return self
end

function ItemTreeLeaf:GetAllItemSize()
	return self.__this:GetAllItemSize()
end

function ItemTreeLeaf:GetItemCount()
	return self.__this:GetItemCount()
end

function ItemTreeLeaf:GetVisibleItemCount()
	return self.__this:GetVisibleItemCount()
end

function ItemTreeLeaf:EnableFormatWhenAppend(...)
	self.__this:EnableFormatWhenAppend(...)
	return self
end

function ItemTreeLeaf:ExchangeItemIndex(...)
	self.__this:ExchangeItemIndex(...)
	return self
end

function ItemTreeLeaf:Sort()
	self.__this:Sort()
	return self
end

function ItemTreeLeaf:IsExpand()
	return self.__this:IsExpand()
end

function ItemTreeLeaf:ExpandOrCollapse(...)
	self.__this:ExpandOrCollapse(...)
	return self
end

function ItemTreeLeaf:Expand()
	self.__this:Expand()
	return self
end

function ItemTreeLeaf:Collapse()
	self.__this:Collapse()
	return self
end

function ItemTreeLeaf:SetIndent(...)
	self.__this:SetIndent(...)
	return self
end

function ItemTreeLeaf:GetIndent()
	return self.__this:GetIndent()
end

function ItemTreeLeaf:SetEachIndentWidth(...)
	self.__this:SetEachIndentWidth(...)
	return self
end

function ItemTreeLeaf:GetEachIndentWidth()
	return self.__this:GetEachIndentWidth()
end

function ItemTreeLeaf:SetNodeIconSize(...)
	self.__this:SetNodeIconSize(...)
	return self
end

function ItemTreeLeaf:SetIconImage(...)
	self.__this:SetIconImage(...)
	return self
end

function ItemTreeLeaf:PtInIcon(...)
	return self.__this:PtInIcon(...)
end

function ItemTreeLeaf:AdjustNodeIconPos()
	self.__this:AdjustNodeIconPos()
	return self
end

function ItemTreeLeaf:AutoSetIconSize()
	self.__this:AutoSetIconSize()
	return self
end

function ItemTreeLeaf:SetShowIndex(...)
	self.__this:SetShowIndex(...)
	return self
end

function ItemTreeLeaf:GetShowIndex()
	return self.__this:GetShowIndex()
end

-- Addon Class
local CreateAddon = class()
local Addon_List = {}
local function CreateAddon_new(__name)
	if not Addon_List[__name] then
		Addon_List[__name] = CreateAddon.new(__name)
	end
	return Addon_List[__name]
end

function CreateAddon:ctor(__name)
	self.__listeners = {self}

	self.__name = __name
	-- Store UI Object By Name
	self.__items = {}

	--Bind Addon Base Events
	self.OnFrameCreate = function()
		self:_FireEvent("OnCreate")
	end
	self.OnFrameBreathe = function()
		self:_FireEvent("OnUpdate")
	end
	self.OnFrameRender = function()
		self:_FireEvent("OnRender")
	end
	self.OnEvent = function(__event)
		self:_FireEvent("OnScript", __event)
	end
end

function CreateAddon:BindEvent(__src, __tar)
	self[__src] = function()
		self:_FireEvent(__tar)
	end
end

function CreateAddon:_FireEvent(__event, ...)
	for __k, __v in pairs(self.__listeners) do
		if __v[__event] then
			local res, err = pcall(__v[__event], self, ...)
			if not res then
				OutputMessage("MSG_SYS", "ERROR:" .. err .. "\n")
			end
		end
	end
end

function CreateAddon:Fetch(__name)
	for k, v in pairs(self.__items) do
		if __name == k then
			return v
		end
	end
	return nil
end

function CreateAddon:CreateMainFrame(__data)
	local __h = WndFrame.new(self.__name, __data)

	-- TODO: not use __items
	self.__items[self.__name] = __h
	return __h
end

function CreateAddon:Append(__type, __parent, __name, __data)
	local __h = nil
	if __data ~= nil and __data.rect ~= nil then
		if __data.rect.x ~= nil then __data.x = __data.rect.x end
		if __data.rect.y ~= nil then __data.y = __data.rect.y end
		if __data.rect.w ~= nil then __data.w = __data.rect.w end
		if __data.rect.h ~= nil then __data.h = __data.rect.h end
	end
	if __type == "Window" then
		__h = WndWindow.new(__parent, __name, __data)
	elseif __type == "PageSet" then
		__h = WndPageSet.new(__parent, __name, __data)
	elseif __type == "Button" then
		__h = WndButton.new(__parent, __name, __data)
	elseif __type == "Edit" then
		__h = WndEdit.new(__parent, __name, __data)
	elseif __type == "CheckBox" then
		__h = WndCheckBox.new(__parent, __name, __data)
	elseif __type == "ComboBox" then
		__h = WndComboBox.new(__parent, __name, __data)
	elseif __type == "RadioBox" then
		__h = WndRadioBox.new(__parent, __name, __data)
	elseif __type == "CSlider" then
		__h = WndCSlider.new(__parent, __name, __data)
	elseif __type == "ColorBox" then
		__h = WndColorBox.new(__parent, __name, __data)
	elseif __type == "Scroll" then
		__h = WndScroll.new(__parent, __name, __data)
	elseif __type == "UICheckBox" then
		__h = WndUICheckBox.new(__parent, __name, __data)
	elseif __type == "Handle" then
		__h = ItemHandle.new(__parent, __name, __data)
	elseif __type == "Text" then
		__h = ItemText.new(__parent, __name, __data)
	elseif __type == "Image" then
		__h = ItemImage.new(__parent, __name, __data)
	elseif __type == "Animate" then
		__h = ItemAnimate.new(__parent, __name, __data)
	elseif __type == "Shadow" then
		__h = ItemShadow.new(__parent, __name, __data)
	elseif __type == "Box" then
		__h = ItemBox.new(__parent, __name, __data)
	elseif __type == "TreeLeaf" then
		__h = ItemTreeLeaf.new(__parent, __name, __data)
	end
	self.__items[__name] = __h
	return __h
end

----------------------------------------------
-- GUI Global Interface
----------------------------------------------
local _API = {
	NewPos = Pos.new,
	CreateFrame = WndFrame.new,
	CreateWindow = WndWindow.new,
	CreatePageSet = WndPageSet.new,
	CreateButton = WndButton.new,
	CreateEdit = WndEdit.new,
	CreateCheckBox = WndCheckBox.new,
	CreateComboBox = WndComboBox.new,
	CreateRadioBox = WndRadioBox.new,
	CreateCSlider = WndCSlider.new,
	CreateColorBox = WndColorBox.new,
	CreateScroll = WndScroll.new,
	CreateUIButton = WndUIButton.new,
	CreateUICheckBox = WndUICheckBox.new,
	CreateHandle = ItemHandle.new,
	CreateText = ItemText.new,
	CreateImage = ItemImage.new,
	CreateAnimate = ItemAnimate.new,
	CreateShadow = ItemShadow.new,
	CreateBox = ItemBox.new,
	CreateTreeLeaf = ItemTreeLeaf.new,
	CreateAddon = CreateAddon_new,
}

do
	EasyUI = {}
	for k, v in pairs(_API) do
		EasyUI[k] = v
	end
end


--~ RegisterEvent("CALL_LUA_ERROR", function()
--~ 	OutputMessage("MSG_SYS", arg0)
--~ end)
