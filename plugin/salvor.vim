nnoremap <silent> <c-t> :call salvor#toggle_terminals()<cr>
nnoremap <silent> <space>tr :call salvor#wipeout()<cr>

autocmd VimEnter * call salvor#initialize()

