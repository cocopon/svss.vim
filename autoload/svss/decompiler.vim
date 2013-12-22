" Author:  cocopon <cocopon@me.com>
" License: MIT License


let s:save_cpo = &cpo
set cpo&vim


let s:indent = "\t"


function! svss#decompiler#decompile(ruleset)
	let blocks = []

	let directives = a:ruleset.directives()
	let header_directives = filter(copy(directives), 'v:val.name() !=# "link"')
	if !empty(directives)
		let block = []
		for directive in header_directives
			call add(block, svss#decompiler#directive(directive))
		endfor
		call add(blocks, block)
	endif

	let definitions = a:ruleset.definitions()
	if !empty(definitions)
		let block = []
		for definition in definitions
			call add(block, svss#decompiler#definition(definition))
		endfor
		call add(blocks, block)
	endif

	let rules = a:ruleset.rules()
	if !empty(rules)
		let block = []
		for rule in rules
			call extend(block, svss#decompiler#rule(rule))
		endfor
		call add(blocks, block)
	endif

	let link_directives = filter(copy(directives), 'v:val.name() ==# "link"')
	if !empty(link_directives)
		let block = []
		for directive in link_directives
			call add(block, svss#decompiler#directive(directive))
		endfor
		call add(blocks, block)
	endif

	let lines = []
	call extend(lines, blocks[0])
	for block in blocks[1:]
		call add(lines, '')
		call add(lines, '')
		call extend(lines, block)
	endfor
	return lines
endfunction


function! svss#decompiler#directive(directive)
	try
		let func_name = printf('svss#decompiler#directive#%s',
					\ a:directive.name())
		let result = function(func_name)(a:directive)
		return result
	catch /:E117:/
		" E117: Unknown function
		throw printf('Unexpected directive: %s',
					\ a:directive.name())
	endtry
endfunction


function! svss#decompiler#definition(definition)
	return printf('$%s: %s',
				\ a:definition.name(),
				\ a:definition.value())
endfunction


function! svss#decompiler#rule(rule)
	let lines = []

	call add(lines, printf('%s {', a:rule.selector()))
	for declaration in a:rule.declarations()
		call add(lines, printf('%s;', svss#decompiler#declaration(declaration)))
	endfor
	call add(lines, '}')

	return lines
endfunction


function! svss#decompiler#declaration(declaration)
	let value = a:declaration.value()
	return printf('%s%s: %s',
				\ s:indent,
				\ a:declaration.property(),
				\ svss#decompiler#value(value))
endfunction


function! svss#decompiler#value(value)
	if type(a:value) != type({})
		" Raw value
		return a:value
	endif

	try
		let type = a:value.type()
		let decompiler_name = printf('svss#decompiler#value#%s',
					\ type)
		let result = function(decompiler_name)(a:value)
		return result
	catch /:E117:/
		" E117: Unknown function
		throw printf('Unexpected value: %s',
					\ string(a:value))
	endtry
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
