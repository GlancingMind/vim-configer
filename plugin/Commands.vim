
command! -complete=dir -nargs=* ConfigerEditConfig
            \ execute 'edit' Configer#GetConfig(<q-args>)
