let s:Config = {}

function! s:SerializeSection(name, settings)
    "wrap settings in function body
    return ['function! '.a:name.'()'] + a:settings + ['endfunction']
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
    let l:name = 's:Config.Beep'
    let l:settings = ['setlocal nonumber', 'echomsg "hello"']
    let l:section = s:SerializeSection(l:name, l:settings)
    let l:config = l:template + [''] + l:section
    call writefile(l:config, 'config.vim')
endfunction

