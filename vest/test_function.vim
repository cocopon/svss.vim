" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


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


Context Source.run()
	It executes lighten
		let ruleset = s:empty_ruleset()
		let original = s:color('rgb', [0x11, 0x22, 0x33])
		let l = s:number(0.1)
		let func = svss#function#new('lighten', [original, l], {})
		let result = svss#function#lighten#execute(ruleset, func)
		ShouldEqual result, '#1d3b59'
	End
End


Fin


let &cpo = s:save_cpo
unlet s:save_cpo
