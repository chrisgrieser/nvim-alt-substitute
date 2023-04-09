describe("parameter processing: ", function()
	local parameters = require("alt-substitute.process-parameters")

	it("Standard Case", function()
		local input = "/search/repl/g"
		local params = parameters.splitByUnescapedSlash(input)
		assert.equals("search", params[1])
		assert.equals("repl", params[2])
		assert.equals("g", params[3])
	end)

	it("escaping the slash", function()
		local input = [[/some\/path/repl/g]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.equals("some/path", params[1])
		assert.equals("repl", params[2])
		assert.equals("g", params[3])
	end)

	it("empty replacement", function()
		local input = [[/foobar//i]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.equals("foobar", params[1])
		assert.equals("", params[2])
		assert.equals("i", params[3])
	end)

	it("no flags", function()
		local input = [[/foo/bar/]]
		local params = parameters.splitByUnescapedSlash(input)
		assert.equals("foo", params[1])
		assert.equals("bar", params[2])
		assert.equals(nil, params[3])
	end)

end)
