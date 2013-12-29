" Author:  cocopon <cocopon@me.com>
" License: MIT License


if exists('b:current_syntax')
  finish
endif

syn keyword svssDirectiveName background license link maintainer name template
syn keyword svssLinkDirectiveTo to contained
syn keyword svssProperty cterm ctermbg ctermfg gui guibg guifg guisp term
syn match svssDirective '@[[:alnum:]]\+' contains=svssDirectiveName
syn match svssFunction '\<\%(adjust-color\|darken\|hsl\|lighten\|mix\|rgb\)\>'
syn match svssLinkDirective '@link\s\+[[:alnum:]]\+\s\+to\s\+[[:alnum:]]\+' contains=svssDirective,svssLinkDirectiveTo
syn match svssNumber '[-+]\=\d\+\(\.\d*\)\=%\='
syn match svssVariable '$[[:alnum:]_-]\+'
syn match svssSpecialCharQ +\\'+ contained
syn match svssSpecialCharQQ +\\"+ contained
syn region svssComment start='^\z(\s*\)//' end='^\%(\z1 \)\@!'
syn region svssDefinition matchGroup=svssBraces start='{' end='}' contains=TOP
syn region svssStringQ start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=svssSpecialCharQ
syn region svssStringQQ start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=svssSpecialCharQQ

hi! def link svssBraces Function
hi! def link svssComment Comment
hi! def link svssDirective Statement
hi! def link svssDirectiveName Statement
hi! def link SvssFunction Function
hi! def link svssLinkDirectiveTo Statement
hi! def link svssNumber Number
hi! def link svssProperty StorageClass
hi! def link svssStringQ String
hi! def link svssStringQQ String
hi! def link svssVariable Identifier

let b:current_syntax = 'svss'
