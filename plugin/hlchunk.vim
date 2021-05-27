hi IndentLineSign ctermfg=248

let s:update_timer = {}
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

func! s:searchpairpos_aux(start, middle, end, flags)
    return searchpairpos(a:start, a:middle, a:end, a:flags,
        \"synIDattr(synID(line('.'), col('.'), 0), 'name') =~? '" .
        \'string\|cppRainbow_lv\d_r\d\|comment' .
        \"'")[0]
endf

func! s:searchpairpos(start, middle, end)
    let c = getline('.')[col('.') - 1]
    if c == a:start
        let ssign = ['zcnWb', 'znW']
    elseif c == a:end
        let ssign = ['znWb', 'zcnW']
    else
        let ssign = ['znWb', 'znW']
    endif
    return [s:searchpairpos_aux('{', '', '}', ssign[0]), s:searchpairpos_aux('{', '', '}', ssign[1])]
endf

func s:hl_chunk(bufnr, id)
    let line = line('.')
    let [beg, end] = s:searchpairpos('{', '', '}')

    call sign_unplace('*', {'buffer' : a:bufnr, 'id' : a:id})
    if beg != 0 || !end == 0
        for idx in range(beg, end)
            call sign_define('IndentLineSign'.idx, { 'numhl': idx == line ? 'CursorLineNr' : 'IndentLineSign'})
            call sign_place(a:id, '', 'IndentLineSign'.idx, a:bufnr, {'lnum': idx, 'priority':90})
        endfor
    endif
endf
