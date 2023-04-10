describe("parameter processing: ", function()
	local splitByUnescapedSlash = require("alt-substitute.process-parameters").splitByUnescapedSlash

	it("Standard Case", function()
		local input = "/search/repl/g"
		local params = splitByUnescapedSlash(input)
		assert.same({"search", "repl", "g"}, params)
	end)

	it("escaping the slash", function()
		local input = [[/some\/path/repl/g]]
		local params = splitByUnescapedSlash(input)
		assert.same({"some/path", "repl", "g"}, params)
	end)

	it("empty replacement", function()
		local input = [[/foobar//i]]
		local params = splitByUnescapedSlash(input)
		assert.same({"foobar", "", "i"}, params)
	end)

	it("no flags", function()
		local input = [[/foo/bar/]]
		local params = splitByUnescapedSlash(input)
		assert.same({"foo", "bar"}, params)
	end)

	it("only flags", function()
		local input = [[///g]]
		local params = splitByUnescapedSlash(input)
		assert.same({"", "", "g"}, params)
	end)

end)
