" ----------------------------------------------------------------
" Config: Lightweight Portable Vim Configuration
" ----------------------------------------------------------------

syn on|filetype plugin indent on
se nocp nu rnu ls=2 sc enc=utf-8 bs=2 ww+=<,>,h,l,[,] hi=256 nobk noswf hls is ai si
se cul nowrap mouse=a mousemodel=popup ts=4 sts=4 sw=4 et
se wmnu wim=longest:full,full so=8 scl=yes sb spr ic scs

let s:is_win = has('win32') || has('win64')
let s:is_win_con = s:is_win && !has('gui_running') && &term ==# 'win32'
let s:is_win_vtp = s:is_win_con && (has('vcon') || !empty($WT_SESSION))
let s:is_linux_tty = !s:is_win && $TERM ==# 'linux'

if s:is_linux_tty
    if has('termguicolors') | set notermguicolors | endif
    if exists('&t_Co') | set t_Co=16 | endif
elseif s:is_win_con
    if has('vcon')
        if exists('&t_Co') && &t_Co < 256 | set t_Co=256 | endif
        if has('termguicolors') | set termguicolors | endif
    else
        if has('termguicolors') | set notermguicolors | endif
    endif
elseif has('termguicolors')
    set termguicolors
endif

try|se cb^=unnamed,unnamedplus|colo habamax|catch|endtry
au FileType javascript,typescript,javascriptreact,typescriptreact,lua,html,css,json,yaml setl ts=2 sw=2 sts=2 et
au FileType org,go,asm,nasm,masm,fasm setl ts=4 sw=4 sts=4 noet
au FileType c,cpp,rust,cs,java,zig,arduino setl ts=4 sw=4 sts=4 et
let mapleader="\<Space>"|nn <space> <nop>|nn <leader>w :w<cr>|nn <leader>q :q<cr>
nn <expr> <BS> col('.')==1?'kgJ':'X'

if has('nvim') || has('gui_running')
    if exists('&guicursor')
        if s:is_linux_tty
            set guicursor=
        else
            set guicursor=n-v-sm:block,i-ci:ver25,c:ver25,r-cr:hor50,o:hor50,ve:ver35,a:blinkwait600-blinkoff600-blinkon600-Cursor/lCursor
        endif
    endif
elseif s:is_linux_tty
    if exists('&guicursor') | set guicursor= | endif
    if exists('&t_SI')
        let &t_SI = "\<Esc>[?2c"
        let &t_SR = "\<Esc>[?4c"
        let &t_EI = "\<Esc>[?6c"
        if stridx(&t_te, "\<Esc>[?16;238;0c") == -1 | let &t_te .= "\<Esc>%G\<Esc>[?16;238;0c" | endif
    endif
elseif s:is_win_con && !s:is_win_vtp
    if exists('&guicursor')
        set guicursor=n-v-sm:block,i-ci:hor15,c:hor15,r-cr:hor50,o:hor50,ve:hor35
    endif
else
    if exists('&guicursor') && s:is_win_con
        set guicursor=
    endif
    if exists('&t_SI')
        let &t_SI = "\<Esc>[5 q"
        let &t_SR = "\<Esc>[3 q"
        let &t_EI = "\<Esc>[1 q"
        if stridx(&t_ti, "\<Esc>[1 q") == -1 | let &t_ti .= "\<Esc>[1 q" | endif
        if stridx(&t_te, "\<Esc>[1 q") == -1 | let &t_te .= "\<Esc>[1 q" | endif
    endif
    if exists('&t_SH') | let &t_SH = "\<Esc>[%d q" | endif

    let s:lite_r_pending = 0
    let s:lite_last_mode = ''

    function! s:lite_cursor_seq(mode) abort
        if a:mode =~# '^no' || a:mode =~# '^R' || a:mode ==# 'cr' || a:mode ==# 'cvr'
            return "\<Esc>[3 q"
        elseif a:mode =~# '^c' || a:mode =~# '^i'
            return "\<Esc>[5 q"
        endif
        return "\<Esc>[1 q"
    endfunction

    function! s:lite_sync_cursor(mode, force) abort
        if !exists('*echoraw')
            return
        endif
        if !a:force && a:mode ==# s:lite_last_mode
            return
        endif
        let s:lite_last_mode = a:mode
        call echoraw(s:lite_cursor_seq(a:mode))
    endfunction

    function! s:lite_end_r() abort
        let s:lite_r_pending = 0
        call s:lite_sync_cursor(mode(1), 1)
    endfunction

    function! s:lite_start_r(is_insert) abort
        if exists('*echoraw')
            call echoraw(s:lite_cursor_seq('R'))
            if exists('##SafeState')
                let s:lite_r_pending = 1
                autocmd SafeState * ++once call s:lite_end_r()
            endif
        endif
        return a:is_insert ? "\<C-o>r" : 'r'
    endfunction

    if exists('##ModeChanged') && exists('*echoraw')
        augroup LiteCursor
            autocmd!
            autocmd VimEnter,VimResume * call s:lite_sync_cursor(mode(1), 1) | if s:is_win_con | let s:lite_last_mode = '' | endif
            autocmd ModeChanged * if !s:lite_r_pending | call s:lite_sync_cursor(v:event.new_mode, 0) | endif
            if exists('##CmdlineEnter')
                autocmd CmdlineEnter * call s:lite_sync_cursor(mode(1), 0)
                autocmd CmdlineLeave * call s:lite_sync_cursor('n', 0)
            endif
            if s:is_win_con
                if exists('##ShellCmdPost') && exists('##FocusGained')
                    autocmd ShellCmdPost,FocusGained * call s:lite_sync_cursor(mode(1), 1) | let s:lite_last_mode = ''
                endif
                if exists('##SafeState')
                    autocmd SafeState * if !s:lite_r_pending && mode(1) !=# s:lite_last_mode | call s:lite_sync_cursor(mode(1), 1) | endif
                endif
            endif
            autocmd VimLeave,VimSuspend * let s:lite_last_mode = '' | call echoraw("\<Esc>[1 q")
        augroup END
    endif

    nnoremap <expr> <silent> r <SID>lite_start_r(0)
    inoremap <expr> <silent> <C-o>r <SID>lite_start_r(1)
endif
