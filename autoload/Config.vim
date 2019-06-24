"Uses this https://stackoverflow.com/questions/31348782/how-do-i-serialize-a-variable-in-vimscript

let s:Config = {
            \'root': '',
            \'configs': []
            \}

function! s:GetAllPossiblePaths(path)
    let l:path = fnamemodify(a:path, ':h')
    if a:path !=# l:path
        return extend([a:path], s:GetAllPossiblePaths(l:path))
    endif
    return [l:path]
endfunction

function! Config#Load(path)
    if filereadable(a:path)
        let l:self = copy(s:Config)
        let l:self.root = a:path
        execute "let l:self.configs = ".readfile(a:path)[0]
        return l:self
    endif
    echohl ErrorMsg
    echomsg string(a:path).' not readable!'
    echohl None
endfunction

function! s:Config.Save(config) dict
    let l:serialize = string(self.configs)
    call writefile([serialize], self.path)
endfunction

function! s:Config.List() dict
    return keys(self.configs)
endfunction

function! s:Config.GetAllConfigsForPath(path) dict
    let l:configs = []
    for l:path in s:GetAllPossiblePaths(resolve(a:path))
        call extend(l:configs, get(self.configs, l:path, []))
    endfor
    return l:configs
endfunction

function! s:Config.GetClosest(path) dict
    for l:path in s:GetAllPossiblePaths(resolve(a:path))
        if has_key(self.configs, l:path)
            return l:path
        endif
    endfor
endfunction

function! s:Config.GetSettings(path) dict
    return get(self.configs, resolve(a:path), [])
endfunction
