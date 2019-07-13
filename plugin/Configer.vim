if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim

"   ==== SETTINGS

let g:Configer_DefaultStorage = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', fnamemodify(getcwd(), ':t'))

let g:Configer_EditConfigDefaultPath = get(g:, 'Configer_EditConfigDefaultPath', expand('%'))

"   ==== COMMANDS

command! -complete=file -nargs=* ConfigerEditConfig
            \ keepalt call Config#Edit(<f-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
