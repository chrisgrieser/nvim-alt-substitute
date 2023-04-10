describe("calculate highlight positions: ", function()
	local calcHighlPos = require("alt-substitute.substitution").calcHighlPos
	local regexFlavor = "lua" -- constant for now
	local lines = {
		'local mod = require("a-module")',
		"foobar foobar foooooobar",
		"",
		"share(20%a); (%w+)bar",
	}

	-- wrapper
	local function calc(params)
		local toSearch = params[1]
		local toReplace = params[2]
		local flags = params[3]
		return calcHighlPos(lines, toSearch, toReplace, flags, regexFlavor)
	end

	-----------------------------------------------------------------------------

	it("Search & Replace (Base)", function()
		local params = { "foobar", "1234", "" }
		local expected = { {}, { { startPos = 1, endPos = 4 } }, {}, {} }
		assert.same(expected, calc(params))
	end)
	it("only search", function()
		local params = { "mod", "", "" }
		local expected = { { { startPos = 7, endPos = 9 } }, {}, {}, {} }
		assert.same(expected, calc(params))
	end)
	it("only search + g flag", function()
		local params = { "mod", "", "g" }
		local expected = { { { startPos = 7, endPos = 9 }, { startPos = 24, endPos = 26 } }, {}, {}, {} }
		assert.same(expected, calc(params))
	end)
	it("g flag", function()
		local params = { "foobar", "1234", "g" }
		local expected = { {}, { { startPos = 1, endPos = 4 }, { startPos = 6, endPos = 9 } }, {}, {} }
		assert.same(expected, calc(params))
	end)
	it("i flag", function()
		local params = { "sHaRe", "xxxxx", "i" }
		local expected = { {}, {}, {}, { { startPos = 1, endPos = 5 } } }
		assert.same(expected, calc(params))
	end)
	it("i flag (control)", function()
		local params = { "sHaRe", "xxxxx", "" }
		local expected = { {}, {}, {}, {} }
		assert.same(expected, calc(params))
	end)
	it("f flag", function()
		local params = { "(%w+)", "fooo", "f" }
		local expected = { {}, {}, {}, { { startPos = 14, endPos = 17 } } }
		assert.same(expected, calc(params))
	end)
	it("only search + digit pattern", function()
		local params = { "%d%d", "", "" }
		local expected = { {}, {}, {}, { { startPos = 7, endPos = 8 } } }
		assert.same(expected, calc(params))
	end)
	it("word pattern w/ quantifier", function()
		local params = { "(%w+)bar", "fooo", "" }
		local expected = { {}, { { startPos = 1, endPos = 4 } }, {}, {} }
		assert.same(expected, calc(params))
	end)


end)
