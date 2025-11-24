if exists("b:current_syntax")
  finish
endif

syn keyword	cStatement	hexDigit digit

syn match   cComment    "//.*\n"
syn region	cString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@Spell
syn match	cNumber		"\<\d\+\>"
syn match	cOperator	"\<[|~()*+?]\>"
syn region	cAttribute	start=+--+ end=+\n+ contains=@Spell
syn match	cLiteral	"\<[a-z][a-zA-Z]*\>"
syn match	cCapLiteral	"\<[A-Z][a-zA-Z]*\>"

hi def link cComment Comment
hi def link cString		String
hi def link cNumber		Number
hi def link cStatement		Statement
hi def link cAttribute		Define
hi def link cLiteral		Constant
hi def link cCapLiteral		Special

