let store = {}
let s:current_state = {}
let s:handlers = []
let s:reducer = {}

function! store#initialize(reducer, initial_state)
  let s:reducer = reducer
  let s:current_state = initial_state
  return store
endfunction

function! store.subscribe(handler)
  let s:handlers += [handler]
endfunction

function! store.get_state()
  return s:current_state 
endfunction

function! store.dispatch(action)
  let new_state = s:reducer(s:current_state, action)
  for handler in s:handlers
    call handler(new_state)
  endfor
  let s:current_state = new_state
endfunction
