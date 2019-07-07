if exists('g:Loaded_Configer')
    finish
endif
let g:Loaded_Configer = 1

let s:save_cpo = &cpo
set cpo&vim

"   ==== SETTINGS

let g:Configer_DefaultStorage = get(g:, 'Configer_ConfigStoragePath', 'vimconfig')

let g:Configer_ConfigFilename = get(g:, 'Configer_ConfigFilename', fnamemodify(getcwd(), ':t'))

"   ==== COMMANDS

command! -complete=dir -nargs=* ConfigerEditConfig keepalt call Configer#ConfigEdit()

command ConfigerApply call Configer#ApplyConfig()

"   ==== AUTOCMDS

augroup vim-configer
    autocmd!
    au! BufEnter * call Configer#ApplyConfig()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
