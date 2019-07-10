let s:Config = {}

function! s:SerializeSection(name, path, settings)
    let l:config = '{
                \"name": "'.a:name.'", "path": "'.a:path.'",
                \"Apply": funcref("s:'.a:name.'"),
                \"settings": s:lines[s:start+1:expand("<slnum>")-3]
                \}'
    return ['let s:start = expand("<slnum>")']
                \+ ['function! s:'.a:name.'()'] + a:settings + ['endfunction']
                \+ ['call Prototype#Register('.l:config.')']
endfunction

function! s:SerializeConfig(config)
    let l:sections = []
    for l:section in a:config
        let l:name = l:section.name
        let l:path = l:section.path
        let l:settings = l:section.settings
        let l:sections += s:SerializeSection(l:name, l:path, l:settings)
    endfor
    return ['let s:lines = readfile(expand("<sfile>"))']
                \+ l:sections
                \+ ['unlet s:start', 'unlet s:lines']
endfunction

function! Prototype#Register(config)
    echomsg 'Registered:' a:config.name 'for' a:config.path
    let s:config = a:config
    echomsg a:config
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

