describe("parameter processing: ", function()
	local parameters = require("alt-substitute.process-parameters")

	it("Standard Case", function()
		local input = "/search/repl/g"
		local params = parameters.splitByUnescapedSlash(input)
		assert.same({"search", "repl", "g"}, params)
	end)

	it("escaping the slash", function()
		local input = [[/some\/path/repl/g]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.same({"some/path", "repl", "g"}, params)
	end)

	it("empty replacement", function()
		local input = [[/foobar//i]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.same({"foobar", "", "i"}, params)
	end)

	it("no flags", function()
		local input = [[/foo/bar/]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.same({"foo", "bar"}, params)
	end)

end)
