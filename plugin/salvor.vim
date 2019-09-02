let s:state = {
      \ 'is_open': 0,
      \ 'tabs': [[]],
      \ 'return_to_window': -1,
      \ 'current_tab': 0,
      \ 'last_focused_buf': -1
      \ }

function! salvor#split_term()
  wincmd v
  terminal
endfunction

function! salvor#initialize()
let s:state = {
      \ 'is_open': 0,
      \ 'tabs': [[]],
      \ 'return_to_window': -1,
      \ 'current_tab': 0,
      \ 'last_focused_buf': -1
      \ }
endfunction

function! salvor#new_tab()
  call salvor#toggle_terminals()
  let s:state.tabs += [[]]
  let s:state.current_tab += 1
  call salvor#toggle_terminals()
endfunction

function! salvor#next_tab()
  if s:state.current_tab == len(s:state.tabs) - 1
    return
  endif
  call salvor#toggle_terminals()
  let s:state.current_tab += 1
  call salvor#toggle_terminals()
endfunction

function! salvor#prev_tab()
  if s:state.current_tab == 0
    return
  endif
  call salvor#toggle_terminals()
    let s:state.current_tab -= 1
  call salvor#toggle_terminals()
endfunction

function! salvor#set_focused_buf()
  let s:state.last_focused_buf = bufnr("%")
endfunction

function! salvor#setup_terminal()
  let current_buf = bufnr("%")
  let current_tab = s:state.tabs[s:state.current_tab]

  if index(current_tab, current_buf) !=# -1
    return
  endif

  setlocal bufhidden=hide

  nnoremap <silent> <buffer> <space>twv :call salvor#split_term()<cr>
  nnoremap <silent> <buffer> <space>ttt :call salvor#new_tab()<cr>
  nnoremap <silent> <buffer> <space>ttn :call salvor#next_tab()<cr>
  nnoremap <silent> <buffer> <space>ttp :call salvor#prev_tab()<cr>

  augroup salvor_local
    autocmd BufEnter <buffer> call salvor#set_focused_buf()
  augroup END

  let s:state.tabs[s:state.current_tab] += [current_buf]
endfunction

function! salvor#dump_state()
  echom "is_open: " . s:state.is_open
  echom "current_tab: " . s:state.current_tab
  echom "last_focused_buf: " . s:state.last_focused_buf
  echo "tabs: " . join(z#map(s:state.tabs, {idx, val -> join(val, ",")}), ",")
endfunction

function! salvor#toggle_terminals()
  if !s:state.is_open
    augroup salvor
      autocmd!
      autocmd TermOpen * call salvor#setup_terminal()
    augroup END
    setlocal winfixheight
    let s:state.return_to_window = winnr()
    let current_tab = s:state.tabs[s:state.current_tab]
    exec "20new"
    if !empty(current_tab)
      let tmpbuf = bufnr("%")
      for buf in current_tab
        noautocmd exec "b" . buf
        if index(current_tab, buf) <= len(current_tab) - 2
          noautocmd wincmd v
        endif
      endfor
      " Clear out the temporary buffer created by switching to
      " the previous terminal buffer
      exec "bwipeout!" . tmpbuf

      " Leave focus in the previously focused terminal buffer
      if s:state.last_focused_buf != -1
        let win = bufwinnr(s:state.last_focused_buf) 
        exec win . "wincmd w"
      endif
    else
      terminal
    endif
    let s:state.is_open = 1
  else
    autocmd! salvor
    for buf in s:state.tabs[s:state.current_tab]
      let win = bufwinnr(buf) 
      noautocmd exec win . "wincmd c"
    endfor
    execute s:state.return_to_window . "wincmd w"
    let s:state.is_open = 0
  endif
endfunction

function! salvor#wipeout()
  for tab in s:state.tabs
    for buf in tab
      exec "bwipeout!" . buf
    endfor
  endfor
  call salvor#initialize()
endfunction

nnoremap <silent> <c-t> :call salvor#toggle_terminals()<cr>
nnoremap <silent> <space>tr :call salvor#wipeout()<cr>
