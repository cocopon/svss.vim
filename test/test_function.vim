" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:function = themis#suite('function')
let s:assert = themis#helper('assert')


function! s:empty_ruleset()
	return svss#ruleset#new([], [], [])
endfunction


function! s:number(value)
	let value = printf('%f', a:value)
	return svss#value#number#new(value)
endfunction


function! s:color(space, num_comps)
	let comps = map(copy(a:num_comps),
				\ 's:number(v:val)')
	return svss#value#color#new(a:space, comps)
endfunction


function! s:function.executes_lighten() abort
	let ruleset = s:empty_ruleset()
	let original = s:color('rgb', [0x11, 0x22, 0x33])
	let l = s:number(0.1)
	let func = svss#function#new('lighten', [original, l], {})
	let result = svss#function#lighten#execute(ruleset, func)
	call s:assert.equals(result, '#1d3b59')

	unlet ruleset original l func result
endfunction


function! s:function.executes_darken() abort
	let ruleset = s:empty_ruleset()

	let original = s:color('rgb', [0xff, 0xee, 0xdd])
	let l = s:number(0.1)
	let func = svss#function#new('darken', [original, l], {})
	let result = svss#function#darken#execute(ruleset, func)
	call s:assert.equals(result, '#ffd4aa')

	let original = s:color('rgb', [0x11, 0x11, 0x11])
	let l = s:number(0.1)
	let func = svss#function#new('darken', [original, l], {})
	let result = svss#function#darken#execute(ruleset, func)
	call s:assert.equals(result, '#000000')

	unlet ruleset original l func result
endfunction


function! s:function.executes_mix() abort
	let ruleset = s:empty_ruleset()
	let color1 = s:color('rgb', [0xff, 0, 0])
	let color2 = s:color('rgb', [0, 0, 0xff])

	let func = svss#function#new('darken', [color1, color2], {})
	let result = svss#function#mix#execute(ruleset, func)
	call s:assert.equals(result, '#7f007f')

	let w = s:number(0.2)
	let func = svss#function#new('darken', [color1, color2, w], {})
	let result = svss#function#mix#execute(ruleset, func)
	call s:assert.equals(result, '#3300cc')

	unlet color1 color2 func result
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
