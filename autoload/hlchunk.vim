let s:cache = {'nr': 0, 'beg': 0, 'end': 0}
" sc1: signcolumn1, sc2: signcolumn2, nc: numbercolumn
let s:mode = get(g:, 'hlchunk_mode', 'sc2')
let s:priority = get(g:, 'hlchunk_priority', 90)
let s:stexts = get(g:, 'hlchunk_stexts', ['╭', '│', '╰'])

func! hlchunk#get_sign_hl_info(bufnr, line)
    if get(g:, 'chunk_hl_log_disabled', 1) == 0
        let l:begintime = log#function_begin(
            \ 'plugin/hlchunk.vim', 'hlchunk#get_sign_hl_info', expand('<sflnum>'),
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

func! hlchunk#searchpairpos_aux(start, middle, end, flags)
    return searchpairpos(a:start, a:middle, a:end, a:flags,
        \"synIDattr(synID(line('.'), col('.'), 0), 'name') =~? '" .
        \'string\|cppRainbow_lv\d_r\d\|comment' .
        \"'")[0]
endf

func! hlchunk#searchpairpos(start, middle, end)
    if get(g:, 'chunk_hl_log_disabled', 1) == 0
        let l:begintime = log#function_begin(
            \ 'plugin/hlchunk.vim', 'hlchunk#searchpairpos', expand('<sflnum>'), 
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

    let l:beg = hlchunk#searchpairpos_aux('{', '', '}', ssign[0])
    let l:end = hlchunk#searchpairpos_aux('{', '', '}', ssign[1])

    if get(g:, 'chunk_hl_log_disabled', 1) == 0
        call log#function_end(l:begintime, [l:beg, l:end])
    endif

    return [beg, end]
endf

func! hlchunk#hl_chunk_aux(bufnr, id)
    let [beg, end] = hlchunk#searchpairpos('{', '', '}')

    if s:mode == 'sc1' || s:mode == 'sc2'
        if s:cache == {'nr': a:bufnr, 'beg': beg, 'end': end} | return | endif
        call sign_unplace('*', {'buffer' : a:bufnr, 'id' : a:id})

        let s:cache = {'nr': a:bufnr, 'beg': beg, 'end': end}
        if beg == end | return | endif
        if beg == 0 || end == 0 | return | endif
        for idx in range(beg, end)
            let hl_info = hlchunk#get_sign_hl_info(a:bufnr, idx)
            let stext = s:stexts[1]
            if idx == beg | let stext = s:stexts[0] | endif
            if idx == end | let stext = s:stexts[2] | endif

            if empty(hl_info)
                let text = s:mode == 'sc1' ? stext : ' ' . stext
                let texthl = 'IndentLineSign'
            else
                let text = s:mode == 'sc1' ? stext : hl_info[0] . stext
                let texthl = hl_info[1]
            endif
            call sign_define('IndentLineSign'.idx, {'text': text, 'texthl': texthl})
            call sign_place(a:id, '', 'IndentLineSign'.idx, a:bufnr, {'lnum': idx, 'priority': s:priority})
        endfor
    else " mode == num
        let line = line('.')
        call sign_unplace('*', {'buffer' : a:bufnr, 'id' : a:id})

        if beg == 0 || end == 0 | return | endif
        for idx in range(beg, end)
            call sign_define('IndentLineSign'.idx, { 'numhl': idx == line ? 'CursorLineNr' : 'IndentLineSign'})
            call sign_place(a:id, '', 'IndentLineSign' . idx, a:bufnr, {'lnum': idx, 'priority': s:priority})
        endfor
    endif
endf

func hlchunk#hl_chunk(bufnr, id)
    if get(g:, 'chunk_hl_log_disabled', 1) == 0
        let l:begtime = log#program_begin()
    endif

    call hlchunk#hl_chunk_aux(a:bufnr, a:id)

    if get(g:, 'chunk_hl_log_disabled', 1) == 0
        return log#program_end(l:begtime)
    endif
endf
