syn keyword cStatement  native math map deltaTime elapsedTime for in listeners match if emit on const
syn keyword cType       number string vector2 vector3 Ref EntitySlice

syn keyword cDefinition entity system nextgroup=cIdentifier skipwhite
syn keyword cPropertyDefinition property nextgroup=cIdentifier skipwhite
syn keyword cComponentDefinition component nextgroup=cIdentifier skipwhite
syn keyword cTemplateDefinition template nextgroup=cIdentifier skipwhite
syn keyword cEventDefinition event nextgroup=cEventIdentifier skipwhite
syn keyword cUpdateStatement update nextgroup=cUpdateStatementEvery skipwhite
syn keyword cUpdateStatementEvery every nextgroup=cUpdateStatementInterval contained skipwhite
syn keyword cUpdateStatementInterval frame nextgroup=cComponentFilter contained skipwhite
syn match cComponentFilter contained "([^)]*)" contains=cComponentFilterComponent
syn match cComponentFilterComponent contained "\<[a-zA-Z_][a-zA-Z_0-9]*\>"
syn match cEventIdentifier contained "\<[a-zA-Z_][a-zA-Z_0-9]*\>" nextgroup=cEventTypeParameters skipwhite
syn match cEventTypeParameters contained "<[^>]*>" contains=cComponentFilterComponent skipwhite
syn keyword cEventListenerStatement on nextgroup=cEventIdentifier skipwhite
syn keyword cQueryExpression query nextgroup=cComponentFilter skipwhite

syn region  cString     start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@Spell
syn match   cNumber     "\<\d\+\>"
syn match   cIdentifier contained "\<[a-zA-Z_][a-zA-Z_0-9]*\>"
syn match   cAccessee   contained "\<[a-zA-Z_][a-zA-Z_0-9]*\>"
syn match   cAccess     contains=cAccessee "\<[a-zA-Z_][a-zA-Z_0-9]*\."
syn match   cComment    "//.*$"

hi def link cNumber     Number
hi def link cString     String
hi def link cStatement  Statement
hi def link cType       Type
hi def link cDefinition Statement
hi def link cPropertyDefinition LspKindProperty
hi def link cComponentDefinition Structure
hi def link cTemplateDefinition Macro
hi def link cEventDefinition Structure
hi def link cEventIdentifier Constant
hi def link cEventListenerStatement Statement
hi def link cIdentifier Constant
hi def link cAccessee   @variable.member
hi def link cUpdateStatement Function
hi def link cUpdateStatementEvery Function
hi def link cUpdateStatementInterval Number
hi def link cComponentFilter Normal
hi def link cComponentFilterComponent Type
hi def link cComment   Comment
