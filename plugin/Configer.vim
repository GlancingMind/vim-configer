if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim

"   ==== SETTINGS

let g:Configer_DefaultStorage = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

"let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', fnamemodify(getcwd(), ':t'))
let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', 'config.vim')

let g:Configer_EditConfigDefaultGlob = get(g:, 'Configer_EditConfigDefaultGlob', expand('%'))

"   ==== COMMANDS

command! -complete=file -nargs=* ConfigerEditConfig
            \ keepalt call Config#Load(g:Configer_ConfigFilename).Edit(<f-args>)

command! -complete=file -nargs=* ConfigerDeleteConfig
            \ call Config#Load(g:Configer_ConfigFilename).Unload(<f-args>)

command! -complete=file ConfigerReloadConfig
            \ call Config#Load(g:Configer_ConfigFilename).Reload()

"   ==== AUTOCMDS

augroup vim-configer
    autocmd BufNewFile,BufReadPost * call Config#Load(g:Configer_ConfigFilename)
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
