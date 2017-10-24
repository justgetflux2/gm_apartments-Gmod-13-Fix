local PANEL = {}
local m_PaperMat = Material("sunabouzu/typewriter_paper")
local m_FontH, m_SizeX, m_CharPerLine = 0, 0, 0
local COLOR_BLACK, COLOR_WHITE = Color(0, 0, 0), Color(255, 255, 255, 200)

function PANEL:DoScrollUp()
	if self:IsScrolling() then
		self.CurrPos = math.Approach(self.CurrPos, self.NewPos, 1.5)
	end
end

function PANEL:IsScrolling()
	return self.CurrPos && self.NewPos && self.CurrPos < self.NewPos
end

function PANEL:Init()

	surface.CreateFont( "typewriter", {
	font  = "Default",
	 size  = ScreenScale( 18 ),
		weight  = 0,
		blursize  = 0,
	scanlines  = 0,
	antialias  = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false
		} )

	self.Lines = {""}
	self.CurrLine = 1
end

function PANEL:Paint()

	surface.SetDrawColor(192, 192, 192, 255)
	surface.SetMaterial(m_PaperMat)

	local x, y = (ScrW() - m_SizeX) / 2, ScrH() - self.CurrPos

	surface.DrawTexturedRect(x, y, m_SizeX, self.CurrPos)

	self:DoScrollUp()

	draw.SimpleText("Press END to exit", "DefaultFixedDropShadow", 15, 15, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	for i = 1, self.CurrLine do
		draw.SimpleText(self.Lines[i] || "", "typewriter", x + 10, y + 10 + (m_FontH * (i - 1)), COLOR_BLACK, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end
end

// Returns true if the character was processed successfully.
function PANEL:AddChar(char)
	if self:AbleToProcessMoreCharacters() then
		self.Lines[self.CurrLine] = self.Lines[self.CurrLine] .. string.char(char)

		return true
	end

	return false
end

function PANEL:NewLine()
	if m_MaxLineCount > self.CurrLine then
		local text = self.Lines[self.CurrLine]

		self.CurrLine = self.CurrLine + 1

		self.Lines[self.CurrLine] = ""

		self:CalcNextLine()

		return text
	end

	return nil
end

function PANEL:CalcNextLine(reset)
	self.NewPos = 20 + (self.CurrLine * m_FontH)

	if reset then
		self.CurrPos = self.NewPos
	end
end

function PANEL:AbleToProcessMoreCharacters()
	return !self:IsScrolling()
		&& self.Lines[self.CurrLine]
		&& #self.Lines[self.CurrLine] <= m_CharPerLine
end

function PANEL:ClearLines()
	if #self.Lines > 0 then
		table.Empty(self.Lines)

		self.CurrLine = 1

		self.Lines[self.CurrLine] = ""

		self:CalcNextLine(true)
	end
end

function PANEL:PerformLayout()
	surface.SetFont("typewriter")
	local w

	w, m_FontH = surface.GetTextSize("W")

	self.CurrPos = 0
	m_SizeX = ScreenScale(512, true)

	m_CharPerLine = math.floor((m_SizeX - 50) / w)
	m_MaxLineCount = math.floor((ScrH() * .8) / m_FontH)
	self:CalcNextLine()
	self:ClearLines()
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
end

vgui.Register("typewriter_paper", PANEL)
