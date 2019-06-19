
command! -complete=dir -nargs=* ConfigerEditLocalConfig
            \ execute 'edit' Configer#GetConfig(<f-args>)
