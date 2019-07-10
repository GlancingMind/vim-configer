let s:Configs = {}

function! Config#Register(config, path)
    echomsg 'Registering:' a:config.name
    call extend(s:Configs, {a:path: a:config})
endfunction

function! s:Serialize(config)
    let l:name = a:config.name
    let l:settings = a:config.settings
    let l:config = '{
                \"name": "'.l:name.'",
                \"Apply": funcref("s:'.l:name.'"),
                \"settings": s:lines[s:start+1:expand("<slnum>")-3]
                \}'
    let l:paths = []
    for l:path in a:config.paths
        let l:paths += ['call Config#Register('.l:config.', "'.l:path.'")']
    endfor

    return ['let s:lines = readfile(expand("<sfile>"))']
                \+ ['let s:start = expand("<slnum>")']
                \+ ['function! s:'.l:name.'()'] + l:settings + ['endfunction']
                \+ l:paths
                \+ ['unlet s:start', 'unlet s:lines']
endfunction

function! Config#Load()
    source config.vim
    for [l:path, l:config] in items(s:Configs)
        echomsg 'Registered:' l:config.name 'for' l:path
        echomsg l:config
    endfor
endfunction

function! Config#Save()
    let l:configs = [
                \{
                    \'name': 'beep',
                    \'paths': ['/hello/beep', '/wonder/ful/world'],
                    \'settings': ['echomsg "hello"']
                \}, {
                    \'name': 'blub',
                    \'paths': ['/blub/world'],
                    \'settings': ['echomsg "world"']
                \}]
    let l:serialized = []
    for l:config in l:configs
        let l:serialized += s:Serialize(l:config)
    endfor
    call writefile(l:serialized, 'config.vim')
endfunction

