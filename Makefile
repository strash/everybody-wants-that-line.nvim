lint: $(wildcard lua/*.lua lua/**/*.lua lua/**/**/*.lua)
	luacheck $?

# Run all test files
test: dependencies/mini.nvim
	nvim --headless --noplugin -u ./tests/minimal_init.lua -c "lua MiniTest.run()"

# Run test from file at `make test_file file=tests/...`
test_file: dependencies/mini.nvim
	nvim --headless --noplugin -u ./tests/minimal_init.lua -c "lua MiniTest.run_file('$(file)')"

# Download 'mini.nvim' to use its 'mini.test' testing module
dependencies:
	mkdir -p dependencies
	git clone --depth 1 https://github.com/echasnovski/mini.nvim dependencies/mini.nvim

clean:
	rm -rf dependencies

.PHONY: lint, test, dependencies

