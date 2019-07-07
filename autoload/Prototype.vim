let s:config = {}

function! s:CreateFunction(name, settings)
    "wrap settings in function body
    let l:section = ['function! '.a:name.'()']
    let l:section += a:settings
    return add(l:section, 'endfunction')
endfunction

function! Prototype#RegisterConfig(config)
    echomsg 'Registered: '.a:config.root
    let s:config = a:config
endfunction

function! Prototype#Load()
    source 'config.vim'
endfunction

function! Prototype#Save()
    let l:template = readfile('templates/Config.vim')
    let l:name = 'Beep'
    let l:settings = ['setlocal nonumber', 'echomsg "hello"']
    let l:section = s:CreateFunction(l:name, l:settings)
    let l:config = l:template + [''] + l:section
    call writefile(l:config, 'config.vim')
endfunction

