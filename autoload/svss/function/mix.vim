" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#function#mix#exists()
	return 1
endfunction


function! svss#function#mix#execute(ruleset, func)
	let args = a:func.arguments()

	let rgb_comps1 = svss#color#split(args[0].evaluate(a:ruleset))
	let rgb_comps2 = svss#color#split(args[1].evaluate(a:ruleset))
	let w = (len(args) < 3)
				\ ? 0.5
				\ : args[2].evaluate(a:ruleset)

	let rgb_comps = []
	for i in [0, 1, 2]
		call add(rgb_comps, rgb_comps1[i] * w + rgb_comps2[i] * (1.0 - w))
	endfor

	return svss#color#join(rgb_comps)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
