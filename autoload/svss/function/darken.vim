" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#function#darken#exists()
	return 1
endfunction


function! svss#function#darken#execute(ruleset, func)
	call svss#function#validate_total_arguments(a:func, 2)
	let args = a:func.arguments()
	let color = args[0]
	let l = args[1].evaluate(a:ruleset)

	let rgb = color.evaluate(a:ruleset)
	let rgb_comps = svss#color#split(rgb)
	let hsl_comps = svss#color#hsl#from_rgb(rgb_comps)
	let hsl_comps[2] = svss#util#bound(hsl_comps[2] - l, 0, 1.0)

	let result_comps = svss#color#hsl#to_rgb(hsl_comps)
	return svss#color#join(result_comps)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

