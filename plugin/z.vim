function! z#map(lst, fn)
  let lst = copy(a:lst)
  return map(lst, a:fn)
endfunction
