" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#function#adjust_color#exists() abort
	return 1
endfunction


function! svss#function#adjust_color#execute(ruleset, func) abort
	call svss#function#validate_total_arguments(a:func, 1)
	let args = a:func.arguments()
	let color = args[0]

	let zero = svss#value#number#new('0')
	let opt_args = a:func.opt_arguments()
	let r = get(opt_args, 'red', zero).evaluate(a:ruleset)
	let g = get(opt_args, 'green', zero).evaluate(a:ruleset)
	let b = get(opt_args, 'blue', zero).evaluate(a:ruleset)
	let h = get(opt_args, 'hue', zero).evaluate(a:ruleset)
	let s = get(opt_args, 'saturation', zero).evaluate(a:ruleset)
	let l = get(opt_args, 'lightness', zero).evaluate(a:ruleset)

	let rgb = color.evaluate(a:ruleset)
	let rgb_comps = svss#color#split(rgb)
	let rgb_comps[0] = svss#util#bound(rgb_comps[0] + r, 0, 255)
	let rgb_comps[1] = svss#util#bound(rgb_comps[1] + g, 0, 255)
	let rgb_comps[2] = svss#util#bound(rgb_comps[2] + b, 0, 255)

	let hsl_comps = svss#color#hsl#from_rgb(rgb_comps)
	let hsl_comps[0] = svss#util#bound(hsl_comps[0] + h, 0, 360)
	let hsl_comps[1] = svss#util#bound(hsl_comps[1] + s, 0, 1.0)
	let hsl_comps[2] = svss#util#bound(hsl_comps[2] + l, 0, 1.0)

	let result_comps = svss#color#hsl#to_rgb(hsl_comps)
	return svss#color#join(result_comps)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
