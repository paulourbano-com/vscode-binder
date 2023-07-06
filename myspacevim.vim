function! myspacevim#before() abort
endfunction

function! myspacevim#after() abort
    map <F4> :TagbarToggle<CR>
    nmap ,e :Files<CR>
    nmap ,g :BTag<CR>
    nmap ,wg :execute ":BTag " . expand('<cword>')<CR>
    nmap ,G :Tags<CR>
    nmap ,wG :execute ":Tags " . expand('<cword>')<CR>
    nmap ,f :BLines<CR>
    nmap ,wf :execute ":BLines " . expand('<cword>')<CR>
    nmap ,F :Lines<CR>
    nmap ,wF :execute ":Lines " . expand('<cword>')<CR>
    nmap ,c :Commands<CR>
endfunction
