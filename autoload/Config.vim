let s:Config = {}

function! Config#Register(config)
    echomsg 'Registered:' a:config.name 'for' a:config.path
    let s:Config = a:config
    echomsg a:config
endfunction

function! s:Serialize(config)
    let l:name = a:config.name
    let l:path = a:config.path
    let l:settings = a:config.settings
    let l:config = '{
                \"name": "'.l:name.'", "path": "'.l:path.'",
                \"Apply": funcref("s:'.l:name.'"),
                \"settings": s:lines[s:start+1:expand("<slnum>")-3]
                \}'

    return ['let s:lines = readfile(expand("<sfile>"))']
                \+ ['let s:start = expand("<slnum>")']
                \+ ['function! s:'.l:name.'()'] + l:settings + ['endfunction']
                \+ ['call Config#Register('.l:config.')']
                \+ ['unlet s:start', 'unlet s:lines']
endfunction

function! Config#Load()
    source config.vim
endfunction

function! Config#Save()
    let l:configs = [
                \{
                    \'name': 'beep',
                    \'path': '/hello/beep',
                    \'settings': ['echomsg "hello"']
                \}, {
                    \'name': 'blub',
                    \'path': '/blub/world',
                    \'settings': ['echomsg "world"']
                \}]
    let l:serialized = []
    for l:config in l:configs
        let l:serialized += s:Serialize(l:config)
    endfor
    call writefile(l:serialized, 'config.vim')
endfunction

