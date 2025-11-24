if exists("b:current_syntax")
  finish
endif

syn match   cComment    "//.*\n"

syn keyword	cStatement	module return const import entry export external mut result
syn keyword	cType	    u8 u16 u32 u64 i8 i16 i32 i64 string

syn region	cString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@Spell
syn match	cNumber		"\<\d\+\>"

hi def link cComment Comment
hi def link cString		String
hi def link cNumber		Number
hi def link cStatement		Statement
hi def link cType       Type
