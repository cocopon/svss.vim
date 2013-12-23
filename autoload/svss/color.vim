" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'evaluate',
			\ 	'components',
			\ 	'space',
			\ 	'type',
			\ ]


function! svss#color#new(space, components)
	let color = {}
	let color.space_ = a:space
	let color.comps_ = a:components

	call svss#util#class#setup_methods(
				\ color,
				\ 'svss#color',
				\ s:method_names)

	return color
endfunction


function! svss#color#type() dict
	return 'color'
endfunction


function! svss#color#space() dict
	return self.space_
endfunction


function! svss#color#components() dict
	return self.comps_
endfunction


function! svss#color#evaluate(ruleset) dict
	let ToRgb = function(printf('svss#color#%s#to_rgb', self.space_))
	let comps = map(copy(self.comps_), 'v:val.evaluate(a:ruleset)')
	let rgb_comps = ToRgb(comps)
	return svss#util#color#join(rgb_comps)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
