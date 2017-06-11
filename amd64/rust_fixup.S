# Even though we state a panic strategy of "abort", this function gets
# referenced. Define it as a do-nothing loop.
#
# This seems to be a bug:
# https://github.com/rust-lang/rust/issues/38281

.global rust_begin_unwind

rust_begin_unwind:
	hlt
	jmp rust_begin_unwind
