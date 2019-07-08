let s:Config = {}

function! s:SerializeSection(name, path, settings)
    "wrap settings in function body
    return ['function! s:'.a:name.'()'] + a:settings + ['endfunction']
                \+ ['call Prototype#RegisterFunction("'.a:path.'", funcref("s:'.a:name.'"))']
endfunction

function! s:SerializeConfig(config)
    let l:sections = []
    for l:section in a:config
        let l:name = l:section.name
        let l:path = l:section.path
        let l:settings = l:section.settings
        let l:sections += s:SerializeSection(l:name, l:path, l:settings)
    endfor
    return l:sections
endfunction

function! Prototype#RegisterConfig(config)
    echomsg 'Registered: '.a:config.root
    let s:config = a:config
endfunction

function! Prototype#RegisterFunction(path, function)
    echomsg a:path a:function
    call a:function()
endfunction

function! Prototype#Load()
    source config.vim
endfunction

function! Prototype#Save()
    let l:config = [
                \{
                    \'name': 'beep',
                    \'path': '/hello/beep',
                    \'settings': ['echomsg "hello"']
                \}, {
                    \'name': 'blub',
                    \'path': '/blub/world',
                    \'settings': ['echomsg "world"']
                \}]
    let l:template = readfile('templates/Config.vim')
    let l:config = s:SerializeConfig(l:config)
    call writefile(l:config, 'config.vim')
endfunction

