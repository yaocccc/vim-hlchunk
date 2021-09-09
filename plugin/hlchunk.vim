hi IndentLineSign ctermfg=248
let s:update_timer = {}
let s:delay = get(g:, 'hlchunk_time_delay', 100)

let [b:hlbeg, b:hlend] = [0, 0]
au TextChanged,TextChangedI,TextChangedP * let [b:hlbeg, b:hlend] = [0, 0]

func HlChunk()
    if [b:hlbeg, b:hlend] != [0, 0] && line('.') > b:hlbeg && line('.') < b:hlend
        return
    endif
    call timer_start(s:delay, s:update_timer.clone(bufnr()).task, {'repeat': 1})
endf

func! s:update_timer.clone(bufnr) abort
    call setbufvar(a:bufnr, 'hl_update_id', getbufvar(a:bufnr, 'hl_update_id', 0) + 1)
    let l:other_timer       = copy(self)
    let l:other_timer.id    = getbufvar(a:bufnr, 'hl_update_id', 0)
    let l:other_timer.bufnr = a:bufnr
    func! l:other_timer.task(timer) abort
        if self.id == getbufvar(self.bufnr, 'hl_update_id', 0)
            call setbufvar(self.bufnr, 'hl_update_count', getbufvar(self.bufnr, 'hl_update_count', 0) + 1)
            call hlchunk#hl_chunk(bufnr(), 999)
        endif
    endf
    return l:other_timer
endf
