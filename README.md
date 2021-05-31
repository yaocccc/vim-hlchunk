# VIM HL CHUNK

hignlight chunk signcolumn plug of vim & nvim

from: [shibinglanya](https://github.com/shibinglanya)

## OPTIONS

```options
  ENGLISH
    " highlight
      au VimEnter * hi IndentLineSign ctermfg=248
    " delay default 100
      let g:hlchunk_time_delay = 100
    " signpriority default 90
      let g:hlchunk_priority = 90
    " hlchunk_theme default 1
      let g:hlchunk_theme = 1

  中文
    " 高亮颜色
      au VimEnter * hi IndentLineSign ctermfg=248
    " 延时 默认为100
      let g:hlchunk_time_delay = 100
    " 优先级 默认为90
      let g:hlchunk_priority = 90
    " 预设主题 默认为1
      let g:hlchunk_theme = 1
```

## USAGE

```usage
  autocmd CursorMoved,CursorMovedI,TextChanged,TextChangedI,TextChangedP *.ts,*.js,*.go call HlChunk()
```

## THEMES

```plaintext
  old: 优先用老的 new: 优先用新的

  1 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [new, new], 中间位置 = [old, new]
  2 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [old, new], 中间位置 = [old, new]
  3 sign_texts: ['╭─', '│ ', '╰>'], 起始位置 = [new, new], 中间位置 = [new, new]

  4 sign_texts: ['│ ', '│ ', '│ '], 起始位置 = [new, old], 中间位置 = [new, old]
  5 sign_texts: ['│ ', '│ ', '│ '], 起始位置 = [new, old], 中间位置 = [old, old]

  6 sign_texts: [' │', ' │', ' │'], 起始位置 = [old, new], 中间位置 = [old, new]
  7 sign_texts: [' │', ' │', ' │'], 起始位置 = [old, old], 中间位置 = [old, new]

  8 sign_texts: ['╭ ', '│ ', '╰ '], 起始位置 = [new, old], 中间位置 = [new, old]
  9 sign_texts: ['╭ ', '│ ', '╰ '], 起始位置 = [new, old], 中间位置 = [old, old]

  10 sign_texts: [' ╭', ' │', ' ╰'], 起始位置 = [old, new], 中间位置 = [old, new]
  11 sign_texts: [' ╭', ' │', ' ╰'], 起始位置 = [old, old], 中间位置 = [old, new]
```

## ENJOY IT
