" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:number = themis#suite('number')
let s:assert = themis#helper('assert')


function! s:empty_ruleset()
	return svss#ruleset#new([], [], [])
endfunction


function! s:number.instanciate_number() abort
	let ruleset = s:empty_ruleset()

	let num = svss#value#number#new('123')
	let result = num.evaluate(ruleset)
	call s:assert.equals(result, 123.0)

	let num = svss#value#number#new('-456')
	let result = num.evaluate(ruleset)
	call s:assert.equals(result, -456.0)

	let num = svss#value#number#new('+789')
	let result = num.evaluate(ruleset)
	call s:assert.equals(result, 789.0)

	let num = svss#value#number#new('3.1416')
	let result = num.evaluate(ruleset)
	call s:assert.equals(result, 3.1416)

	unlet ruleset num result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
