syn on|filetype plugin indent on
se nocp nu rnu ls=2 sc enc=utf-8 bs=2 ww+=<,>,h,l,[,] hi=256 nobk noswf hls is ai si
se tgc cul nowrap mouse=a mousemodel=popup ts=4 sts=4 sw=4 et
se wmnu wim=longest:full,full so=8 scl=yes sb spr ic scs
try|se cb^=unnamed,unnamedplus|colo habamax|catch|endtry
au FileType javascript,typescript,javascriptreact,typescriptreact,lua,html,css,json,yaml setl ts=2 sw=2 sts=2 et
au FileType python,org,go,asm,nasm,masm,fasm setl ts=4 sw=4 sts=4 noet
au FileType c,cpp,rust,cs,java,zig,arduino setl ts=4 sw=4 sts=4 et
let mapleader="\<Space>"|nn <space> <nop>|nn <leader>w :w<cr>|nn <leader>q :q<cr>
nn <expr> <BS> col('.')==1?'kgJ':'X'
let &t_SI="\<Esc>[5 q"|let &t_SR="\<Esc>[3 q"|let &t_EI="\<Esc>[1 q"
