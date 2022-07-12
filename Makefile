.PHONY: lint
lint: $(wildcard lua/*.lua lua/**/*.lua)
	luacheck $?

