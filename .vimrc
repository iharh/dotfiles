set nocp

"source $HOME/dotfiles/vimrc.basic

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
"Plug 'itchyny/lightline.vim'

Plug 'ekalinin/Dockerfile.vim'
Plug 'rking/ag.vim'
Plug 'derekwyatt/vim-scala'
Plug 'derekwyatt/vim-sbt'
Plug 'udalov/kotlin-vim'
Plug 'rust-lang/rust.vim'
" Plug 'racer-rust/vim-racer'
Plug 'leafgarland/typescript-vim'
Plug 'digitaltoad/vim-pug'
" Plug 'NLKNguyen/papercolor-theme'

" Add plugins to &runtimepath
call plug#end()
" :PlugInstall, :PlugUpdate

"" airline stuff
set ls=2 "laststatus
let g:airline_powerline_fonts = 1
" Useful status information at bottom of screen
"set statusline=[%n]\ %<%.99f\ %h%w%m%r%y\ %{exists('*CapsLockStatusline')?CapsLockStatusline():''}%=%-16(\ %l-%L,%c-%v\ %)%P
" :AirlineTheme
let g:airline_theme='badwolf'   " badwolf PaperColor

"set background=light
"colorscheme PaperColor

" lightline stuff
" 'colorscheme' : 'solarized'
"let g:lightline = { 'active': {'right': [ [ 'lineinfo' ], [ 'percent' ], [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ] }, 'component': { 'charvaluehex': '0x%B' }, }

syn on                         " (syntax)   - turn on syntax highlighting
filet plugin indent on         " (filetype) - turn on file type detection.

" fix tab behaviour in normal mode
" Note the extra space after the second \
set list lcs=tab:\ \ 

" autocomplete for help works, but still have problems with file-path-names
"set wildchar=9
set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.

set showcmd                       " Display incomplete commands.
set showmode                      " Display the mode you're in.


set hidden                        " Handle multiple buffers better.

set ignorecase                    " Case-insensitive searching.
"set smartcase                     " But case-sensitive if expression contains a capital letter.

"set number                        " Show line numbers.
set ruler                         " Show cursor position.

set incsearch                     " Highlight matches as you type.
set hlsearch                      " Highlight matches.

"set nopaste/paste                         " Do not autoindent while doing paste
"http://stackoverflow.com/questions/2514445/turning-off-auto-indent-when-pasting-text-into-vim

set wrap                          " Turn on line wrapping.
set scrolloff=3                   " Show 3 lines of context around the cursor.
set nostartofline                 " Do not go to the start of line on scrolling like C-F/C-B/...

set title                         " Set the terminal's title

"set visualbell                    " No beeping.

set nobackup                      " Don't make a backup before overwriting a file.
set nowritebackup                 " And again.
"set directory=$HOME/.vim/tmp//,.  " Keep swap files in one location

" set nowrap

set autoindent                      " auto-indent
set path=.,,**

set hh=40                           " helpheight

" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" This tip is an improved version of the example given for :help last-position-jump.
" It fixes a problem where the cursor position will not be restored if the file only has a single line. 
"
" Tell vim to remember certain things when we exit
"  '50  :  marks will be remembered for up to 10 previously edited files
"  "100 :  will save up to 100 lines for each register
"  :20  :  up to 20 lines of command-line history will be remembered
"  %    :  saves and restores the buffer list
"  n... :  where to save the viminfo files
set viminfo='50,\"100,:20,%,n~/_viminfo

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

set tags=./tags;/


"vimfiler settings
" Enable file operation commands.
let g:vimfiler_safe_mode_by_default = 0

" Disable netrw.vim
"let g:loaded_netrwPlugin = 1

" To rebuild the help tags
":helpt[ags] s:vimfilesbase . doc

" need not to be very early!
if has('win32') || has('win64')
" for hiding ^M while viewing DOS-files
  set fileformats=dos
  set fileformat=dos
endif


" default file type
"au BufEnter * if &ft == "" | setlocal ft=text | endif

" UNCOMMENT TO USE
"ts tabstop                      " Global tab width.
"sw shiftwidth=2                 " And again, related.
"et expandtab                    " Use spaces instead of tabs

"au[tocmd] setl[ocal] 
"au setl sw=4 sts=4 et
au FileType cpp setl sw=4 sts=4 et
au FileType c setl sw=4 sts=4 et
au FileType java setl sw=4 sts=4 et
au FileType kotlin setl sw=4 sts=4 et
au FileType scala setl sw=4 sts=4 et
au FileType d setl sw=4 sts=4 et
au FileType sdl setl sw=4 sts=4 et
au FileType sbt setl sw=4 sts=4 et
au FileType python setl sw=4 sts=4 et
au FileType ruby setl sw=2 sts=2 et
au FileType haskell setl sw=4 sts=4 noeol
au FileType cabal setl sw=4 sts=4 noeol
au FileType sql setl sw=4 sts=4 et
au FileType ant setl sw=4 sts=4 et
au FileType xml setl sw=4 sts=4 et
au FileType html setl sw=4 sts=4 et
au FileType text setl sw=4 sts=4 et noeol
au FileType conf setl sw=4 sts=4 et noeol
au FileType vim setl sw=4 sts=4 et
au FileType javascript setl sw=4 sts=4 et
au FileType nsis setl sw=4 sts=4 et
au FileType groovy setl sw=4 sts=4 et
au FileType Dockerfile setl sw=4 sts=4 et
au FileType dosbatch setl sw=4 sts=4 et
au FileType json setl sw=4 sts=4 et
au FileType sh setl sw=4 sts=4 et
au FileType zsh setl sw=4 sts=4 et
au FileType proto setl sw=4 sts=4 et
au FileType perl setl sw=4 sts=4 et
au FileType typescript setl sw=4 sts=4 et
au FileType pug setl sw=2 sts=2 et
au FileType yaml setl sw=2 sts=2 et
" for t in ['cpp', 'java', 'sql']  DOES NOT WORK
" endfor
" set ft - to check the current filetype

" rust
au BufRead,BufNewFile *.crs set filetype=rust

" gradle syntax highlighting
au BufRead,BufNewFile *.gradle set filetype=groovy

" Dockerfile
au BufRead,BufNewFile *.dock setf Dockerfile
au BufRead,BufNewFile *.sbt set filetype=sbt
au BufRead,BufNewFile *.sc set filetype=scala
"sbt.scala

" https://github.com/JesseKPhillips/d.vim/blob/master/ftdetect/dsdl.vim
autocmd BufNewFile,BufRead *.sdl set filetype=dsdl

"easier buffer/tabs navigation
map <C-J>  :bn<CR>
map <C-K>  :bp<CR>
map <C-L>  :tabn<CR>
map <C-H>  :tabp<CR>

" QuickFix navigation
" http://blog.sofistes.net/2013/10/effective-quickfix-window-use-in-vim.html
map <A-p> :cp<CR> 
map <A-n> :cn<CR> 
map <A-P> :colder<CR>
map <A-N> :newer<CR>

" /usr/share/vim/vim80
" source $VIMRUNTIME/mswin.vim
" behave mswin

" backspace and cursor keys wrap to previous/next line
set backspace=indent,eol,start whichwrap+=<,>,[,]

" backspace in Visual mode deletes selection
vnoremap <BS> d

if has("clipboard")
    " CTRL-X and SHIFT-Del are Cut
    vnoremap <C-X> "+x
    vnoremap <S-Del> "+x

    " CTRL-C and CTRL-Insert are Copy
    vnoremap <C-C> "+y
    vnoremap <C-Insert> "+y

    " CTRL-V and SHIFT-Insert are Paste
    map <C-V>		"+gP
    map <S-Insert>		"+gP

    cmap <C-V>		<C-R>+
    cmap <S-Insert>		<C-R>+
endif

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
" Uses the paste.vim autoload script.
" Use CTRL-G u to have CTRL-Z only undo the paste.

if 1
    exe 'inoremap <script> <C-V> <C-G>u' . paste#paste_cmd['i']
    exe 'vnoremap <script> <C-V> ' . paste#paste_cmd['v']
endif

imap <S-Insert>		<C-V>
vmap <S-Insert>		<C-V>

" Use CTRL-Q to do what CTRL-V used to do
noremap <C-Q>		<C-V>

" For CTRL-V to work autoselect must be off.
" On Unix we have two selections, autoselect can be used.
if !has("unix")
  set guioptions-=a
endif

" CTRL-Z is Undo; not in cmdline though
noremap <C-Z> u
inoremap <C-Z> <C-O>u

" CTRL-Y is Redo (although not repeat); not in cmdline though
noremap <C-Y> <C-R>
inoremap <C-Y> <C-O><C-R>

" restore visual mode selection after indenting
vmap < <gv
vmap > >gv
