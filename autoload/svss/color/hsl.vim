" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


function! svss#color#hsl#to_rgb(comps) abort
	if len(a:comps) != 3
		return []
	endif

	let h = svss#util#bound(a:comps[0], 0, 360)
	let s = svss#util#bound(a:comps[1], 0, 1.0)
	let l = svss#util#bound(a:comps[2], 0, 1.0)

	let max = (l <= 0.5) ? (l * (1 + s)) : (l * (1 - s) + s)
	let min = 2 * l - max

	let hh = h + 120
	if hh >= 360
		let hh -= 360
	endif
	let r = s:hsl2rgb_comp(hh, min, max)

	let hh = h
	if hh >= 360
		let hh = 0
	endif
	let g = s:hsl2rgb_comp(hh, min, max)

	let hh = h - 120
	if hh < 0
		let hh += 360
	endif
	let b = s:hsl2rgb_comp(hh, min, max)

	return [r, g, b]
endfunction


function! svss#color#hsl#from_rgb(comps) abort
	if len(a:comps) != 3
		return []
	endif

	let rgb = copy(a:comps)
	let r = svss#util#bound(rgb[0] / 255.0, 0, 1.0)
	let g = svss#util#bound(rgb[1] / 255.0, 0, 1.0)
	let b = svss#util#bound(rgb[2] / 255.0, 0, 1.0)

	let max = (r > g) ? r : g
	let max = (max > b) ? max : b
	let min = (r < g) ? r : g
	let min = (min < b) ? min : b
	let c = max - min
	let h = 0
	let s = 0
	let l = (min + max) / 2.0

	if c != 0
		let s = (l > 0.5) ? (c / (2 - min - max)) : (c / (max + min))

		if r == max
			let h = (g - b) / c
		elseif g == max
			let h = 2.0 + (b - r) / c
		elseif b == max
			let h = 4.0 + (r - g) / c
		endif

		let h = h / 6.0 + ((h < 0) ? 1.0 : 0)
	endif

	return [
				\ 	h * 360,
				\ 	s,
				\ 	l
				\ ]
endfunction


function! s:hsl2rgb_comp(comp, min, max) abort
	let c = a:comp
	let result = 0

	if c >= 0 && c < 60
		let result = a:min + (a:max - a:min) * c / 60
	elseif c >= 60 && c < 180
		let result = a:max
	elseif c >= 180 && c < 240
		let result = a:min + (a:max - a:min) * (240 - c) / 60
	else
		let result = a:min
	endif

	return result * 255.0
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
