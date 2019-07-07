function! s:CreateFunction(name, settings)
    "wrap settings in function body
    let l:section = ['function! '.a:name.'()']
    let l:section += a:settings
    return add(l:section, 'endfunction')
endfunction

function! Configer#Save()
    let l:name = 'beepboop'
    let l:settings = ['set nonumber', 'echomsg "hello"']
    let l:section = s:CreateFunction(l:name, l:settings)
    call writefile(l:section, 'config')
endfunction
