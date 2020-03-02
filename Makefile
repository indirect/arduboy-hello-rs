#IDE_PATH := ${HOME}/opt/arduino-1.8.5
#PORT := /dev/ttyACM0

BIN_PATH := /Applications/Arduino.app/Contents/MacOS
AVR_PATH := /Users/andre/Library/Arduino15/packages/arduino/hardware/avr/1.8.2
PORT := 1

ifndef PORT
$(error PORT is not defined)
endif

SYSROOT := $(shell rustc +avr --print sysroot)
SRCROOT := /Users/andre/src/avr-rust/rust

# TODO Better implementation
# see https://github.com/arduino/Arduino/pull/5338
IDE_PREF := $(shell grep -E '^recipe\.c\.combine\.pattern=.*$$' \
			'$(AVR_PATH)/platform.txt' \
		| gsed -r 's@(.*)@\1 target/arduboy/release/libhello.a@')

verify:
	$(call do_build,--verify)
upload:
	$(call do_build,--upload)

define do_build
	: IDE_PATH := $(IDE_PATH)
	: PORT := $(PORT)
	: SYSROOT := $(SYSROOT)
	: IDE_PREF := $(IDE_PREF)
	: ----------build-rust-program----------
	RUST_BACKTRACE=1 \
	XARGO_RUST_SRC='$(SRCROOT)/src' \
	RUSTC='$(SYSROOT)/bin/rustc' \
	RUSTDOC='$(SYSROOT)/bin/rustdoc' \
	xargo build -vvv --release --target=arduboy
	: ----------build-arduboy-game----------
	'$(BIN_PATH)/Arduino' $1 -v --board arduboy:avr:arduboy \
		--port '$(PORT)' --pref '$(IDE_PREF)' ffi.ino
endef

.PHONY: verify upload
