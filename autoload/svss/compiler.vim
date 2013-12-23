" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:method_names = [
			\ 	'compile',
			\ 	'compile_color_',
			\ 	'compile_declaration_',
			\ 	'compile_internal_',
			\ 	'compile_link_',
			\ 	'compile_rule_',
			\ 	'compile_value_',
			\ ]
let s:simple_directives = [
			\ 	'background',
			\ 	'license',
			\ 	'maintainer',
			\ 	'name',
			\ ]
let s:date_format = '%Y-%m-%d %H:%M%z'


function! svss#compiler#new()
	let compiler = {}
	let compiler.bang_ = 1
	let compiler.def_ = 0

	call svss#util#class#setup_methods(
				\ compiler,
				\ 'svss#compiler',
				\ s:method_names)

	return compiler
endfunction


function! svss#compiler#compile_color_(ruleset, color) dict
	let ToRgb = function(printf('svss#color#%s#to_rgb', a:color.space()))
	let comps = map(a:color.components(), 'v:val.calculate(a:ruleset)')
	let rgb_comps = ToRgb(comps)
	return svss#util#color#join(rgb_comps)
endfunction


function! svss#compiler#compile_value_(ruleset, value) dict
	if !exists('a:value.type')
		return a:value
	endif

	return a:value.calculate(a:ruleset)
endfunction


function! svss#compiler#compile_declaration_(ruleset, rule, declaration) dict
	let value = a:declaration.value()
	return printf('%s=%s',
				\ a:declaration.property(),
				\ self.compile_value_(a:ruleset, value))
endfunction


function! svss#compiler#compile_rule_(ruleset, rule) dict
	let declarations = a:rule.declarations()
	if empty(declarations)
		return ''
	endif

	let args = []
	for declaration in declarations
		call add(args, self.compile_declaration_(a:ruleset, a:rule, declaration))
	endfor

	let cmds = []
	for selector in a:rule.selectors()
		let comps = ['hi' . (self.bang_ ? '!' : '')]
		if self.def_
			call add(comps, 'def')
		endif
		call add(comps, selector)
		call add(comps, join(args))

		call add(cmds, join(comps))
	endfor

	return cmds
endfunction


function! svss#compiler#compile_link_(directive) dict
	let comps = ['hi' . (self.bang_ ? '!' : '')]
	if self.def_
		call add(comps, 'def')
	endif
	call add(comps, 'link')

	call add(comps, a:directive.argument(0))
	call add(comps, a:directive.argument(1))

	return join(comps)
endfunction


function! svss#compiler#compile_internal_(ruleset) dict
	let result = {}

	for name in s:simple_directives
		let directives = a:ruleset.find_directives(name)
		if empty(directives)
			throw printf('Requried directive not found: %s',
						\ name)
		endif
		let result[name] = directives[0].argument(0)
	endfor

	let result.date = strftime(s:date_format)
	let result.file = printf('%s.vim', result.name)

	let hi_cmds = []
	for rule in a:ruleset.rules()
		call extend(hi_cmds, self.compile_rule_(a:ruleset, rule))
	endfor
	call add(hi_cmds, '')
	for directive in a:ruleset.find_directives('link')
		call add(hi_cmds, self.compile_link_(directive))
	endfor
	let result.highlights = hi_cmds

	return result
endfunction


function! svss#compiler#compile(ruleset) dict
	if get(g:, 'svss_debug', 0)
		return self.compile_internal_(a:ruleset)
	endif

	try
		return self.compile_internal_(a:ruleset)
	catch
		throw printf('Compile error: %s',
				\ v:exception)
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
