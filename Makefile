lint:
	@printf "\nRunning luacheck\n"
	luacheck lua/**/*.lua

.PHONY: test lint
