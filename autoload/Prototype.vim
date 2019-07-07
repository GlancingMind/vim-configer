let s:Config = {}

function! s:SerializeSection(name, settings)
    "wrap settings in function body
    return ['function! '.a:name.'()'] + a:settings + ['endfunction']
endfunction

"TODO maybe remove template and instead init s:Config, which will be
"serialized
function! s:SerializeConfig(config)
    "let l:config = ['let s:Config = '.string(a:config)]
    let l:sections = []
    for [l:name, l:settings] in items(a:config)
        let l:register = 'call Prototype#RegisterFunction(funcref("'.l:name.'"))'
        let l:sections += s:SerializeSection(l:name, l:settings) + [l:register]
    endfor
    return l:sections
endfunction

function! Prototype#RegisterConfig(config)
    echomsg 'Registered: '.a:config.root
    let s:config = a:config
endfunction

function! Prototype#RegisterFunction(function)
    echomsg a:function
    call a:function()
endfunction

function! Prototype#Load()
    source config.vim
endfunction

function! Prototype#Save()
    let l:config = {'Beep': ['echomsg "hello"'], 'Boop': ['echomsg "world"']}
    let l:template = readfile('templates/Config.vim')
    let l:config = s:SerializeConfig(l:config)
    call writefile(l:config, 'config.vim')
endfunction

