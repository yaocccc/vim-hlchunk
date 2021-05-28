


function! log#enable()
	let g:chunk_hl_log_disabled = 0
endfunction

function! log#disable()
	let g:chunk_hl_log_disabled = 1
endfunction

function! s:writefile(...) abort
	if !empty(trim(get(g:, 'hlchunk_log_file', '')))
		call writefile([strftime("[%H:%M]"). join(a:000, ' ')], 
					\ g:hlchunk_log_file, 'a')
	endif
endfunction

function! log#function_begin(file_name, fun_name, slnum, arg) abort
	return [reltime(), a:file_name, a:fun_name, a:slnum, a:arg]
endfunction

function! log#function_end(begin, return, ...) abort
	let l:info = join(a:000, '')
	call s:writefile(
				\ printf('%s(%s-%s)', a:begin[1], a:begin[3], a:begin[2]), 
				\ printf('{用时:%s}', trim(reltimestr(reltime(a:begin[0])))))
	call s:writefile('	', printf('{参数:%s}', a:begin[4]))
	call s:writefile('	', printf('{返回:%s}', a:return))
	if !empty(l:info)
		call s:writefile('	', l:info)
	endif
endfunction

function! s:clear_screen()
	for idx in range(10)
		call writefile([''], g:hlchunk_log_file, 'a')
	endfor
endfunction

function! log#program_begin()
	call s:clear_screen()
	call s:writefile('-------开始运行-------')
	return [reltime()]
endfunction

function! log#program_end(begin)
	call s:writefile('-------结束运行-------') 
	call s:writefile('用时：'. trim(reltimestr(reltime(a:begin[0]))))
endfunction

