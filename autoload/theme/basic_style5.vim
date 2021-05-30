

func theme#basic_style5#init()
	hi def IndentLineSign ctermfg=205 cterm=bold
	call sign_detector#run('{', '', '}')
	augroup HlChunk
		autocmd!
		autocmd User SelfSignChanged call s:self_sign_changed()
		autocmd User OtherSignHidden call s:other_sign_hidden()
	augroup END
endf

function! s:self_sign_changed()
	call sign_detector#place(' │', 'IndentLineSign')
endfunction

func s:other_sign_hidden()
	call sign_detector#place(' '. trim(b:sd_sign_defined.text), b:sd_sign_defined.texthl)
endfunction
