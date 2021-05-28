hi IndentLineSign ctermfg=248

let s:update_timer = {}

autocmd CursorMoved,CursorMovedI *.cpp call HlChunk()

func HlChunk()
    call timer_start(100, s:update_timer.clone(bufnr()).task, {'repeat': 1})
endf

func! s:update_timer.clone(bufnr) abort
    call setbufvar(a:bufnr, 'hl_update_id', getbufvar(a:bufnr, 'hl_update_id', 0) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getbufvar(a:bufnr, 'hl_update_id', 0)
    let l:other_timer.bufnr = a:bufnr
    func! l:other_timer.task(timer) abort
        if self.id == getbufvar(self.bufnr, 'hl_update_id', 0)
            call setbufvar(self.bufnr, 'hl_update_count', getbufvar(self.bufnr, 'hl_update_count', 0) + 1)
            call s:hl_chunk(bufnr(), 999)
        endif
    endf
    return l:other_timer
endf

func! s:get_sign_hl_info(bufnr, line)
	if get(g:, 'chunk_hl_log_disabled', 1) == 0
		let l:begintime = log#function_begin(
					\ 'plugin/hlchunk.vim', 's:get_sign_hl_info', expand('<sflnum>'),
					\ deepcopy([a:bufnr, a:line]))
	endif

	let signs = sign_getplaced(a:bufnr, {'group':'*', 'lnum':a:line})[0].signs
	if empty(signs) | return [] | endif
	call sort(signs, {v1, v2->v1.priority < v2.priority})
	let hl_info = sign_getdefined(signs[0].name)

	if get(g:, 'chunk_hl_log_disabled', 1) == 0
		call log#function_end(l:begintime, [trim(hl_info[0].text, ' '), hl_info[0].texthl])
	endif

	return [trim(hl_info[0].text, ' '), hl_info[0].texthl]
endf

func! s:searchpairpos_aux(start, middle, end, flags)
    return searchpairpos(a:start, a:middle, a:end, a:flags,
        \"synIDattr(synID(line('.'), col('.'), 0), 'name') =~? '" .
        \'string\|cppRainbow_lv\d_r\d\|comment' .
        \"'")[0]
endf

func! s:searchpairpos(start, middle, end)
	if get(g:, 'chunk_hl_log_disabled', 1) == 0
		let l:begintime = log#function_begin(
					\ 'plugin/hlchunk.vim', 's:searchpairpos', expand('<sflnum>'), 
					\ deepcopy([a:start, a:middle, a:end]))
	endif

    let c = getline('.')[col('.') - 1]
    if c == a:start
        let ssign = ['zcnWb', 'znW']
    elseif c == a:end
        let ssign = ['znWb', 'zcnW']
    else
        let ssign = ['znWb', 'znW']
    endif
		let l:beg = s:searchpairpos_aux('{', '', '}', ssign[0])
		let l:end = s:searchpairpos_aux('{', '', '}', ssign[1])

		if get(g:, 'chunk_hl_log_disabled', 1) == 0
			call log#function_end(l:begintime, [l:beg, l:end])
		endif

		return [beg, end]
endf

let s:cache = {'nr': 0, 'beg': 0, 'end': 0}
function! s:hl_chunk_aux(bufnr, id)
		let [beg, end] = s:searchpairpos('{', '', '}')
    if beg == end
			return
		endif
    if s:cache == {'nr': a:bufnr, 'beg': beg, 'end': end} | echo 1 | return | endif

    call sign_unplace('*', {'buffer' : a:bufnr, 'id' : a:id})
    for idx in range(beg, end)
        let hl_info = s:get_sign_hl_info(a:bufnr, idx)
        let stext = '│'
        if idx == beg | let stext = '╭' | endif
        if idx == end | let stext = '╰' | endif
        if empty(hl_info)
            call sign_define('IndentLineSign'.idx, {'text': ' ' . stext, 'texthl': 'IndentLineSign'})
        else
            call sign_define('IndentLineSign'.idx, {'text': hl_info[0] . stext, 'texthl': hl_info[1]})
        endif
        call sign_place(a:id, '', 'IndentLineSign'.idx, a:bufnr, {'lnum': idx, 'priority':90})
    endfor

    let s:cache = {'nr': a:bufnr, 'beg': beg, 'end': end}
endfunction

func s:hl_chunk(bufnr, id)
		if get(g:, 'chunk_hl_log_disabled', 1) == 0
			let l:begtime = log#program_begin()
		endif

		call s:hl_chunk_aux(a:bufnr, a:id)

		if get(g:, 'chunk_hl_log_disabled', 1) == 0
			return log#program_end(l:begtime)
		endif
endf

let g:hlchunk_log_file = '/tmp/hlchunk.log'



command! HlChunkLogEnable call  log#enable()
command! HlChunkLogDisable call log#disable()
