set nocompatible
filetype off
"for plugin manager Vundle

"set runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"Required. Lets Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" Plugins go here in between begin() and end()

Plugin 'https://github.com/guns/xterm-color-table.vim.git'
" All 256 xterm colors with their RGB equivalents, right in Vim!
" prints a color table to screen to see available term colors on this machine

Plugin 'https://github.com/ap/vim-css-color.git'
" highlights color hex codes

"All plugins must be added before following line:
call vundle#end()  "required
filetype plugin indent on  "required

"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"Put non-plugin stuff after this line

"colorscheme
colorscheme elflord

"show line numbers
set number
set numberwidth=4

"highlight searches
set hlsearch

"tab=4spaces settings
set tabstop=4
set shiftwidth=4
set expandtab

"for lines that wrap (too long to fit in window width)
:let &showbreak = ' >>    '
:set cpoptions+=n "lines up showbreak characters with line number column
:set wrap
:set linebreak
:set nolist

"maps keystroke(s)  <a> onto <b> in: noremap <a> <b>
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-Down> <C-w>j
noremap <C-Up> <C-w>k
noremap <C-Right> <C-w>l
noremap <C-Left> <C-w>h
noremap <S-l> :bnext<CR>
noremap <S-h> :bprev<CR>
noremap <S-Left> :bprev<CR>
noremap <S-Right> :bnext<CR

"enable mouse support
:set mouse=a

"case insensitive search by default (\c)
"override with \C when searching
:set ignorecase

"enable persistent undo
"requires dir ~/.vim/undodir to exist, so if you get an error, mkdir
set undodir=~/.vim/undodir
set undofile

"in insert mode toggle paste mode to switch b/w
"preserve indentation of pasted text (==> :set paste)
"or to use normal audo-indent (==> :set nopaste)
set pastetoggle=<F2>
"allows doing the same thing while still in normal mode
nnoremap <F2> :set invpaste paste?<CR>
"shows whether in paste mode in normal mode (already will show in insert mode)
set showmode

" map space bar to turn off highlight after most recent search
"(highlight will return after next serach)
:nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Press F4 to toggle search highlighting on/off, and show current value.
:noremap <F4> :set hlsearch! hlsearch?<CR>

"highlight trailing whitespace in red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"highlight any tab characters
function! Tabs()
    syntax match TAB /\t/
    hi TAB ctermbg=7 guibg=DarkGrey
endfunction
au BufEnter,BufRead * call Tabs()

" my custom highlight colors for running vimdiff form command line
if &diff
  hi diffchange ctermbg=5
  hi diffdelete ctermbg=1
  hi diffadd ctermbg=2 ctermfg=7
  hi difftext ctermbg=2 ctermfg=8
endif

" slightly changed but this is from kyokley github https://gist.github.com/kyokley/0d7bb03eede831bea3fa
" https://gist.github.com/kyokley/3e868a6575d28cb4020694876d8f16b7
" checks for python errors w/ pyflakes
" & checks for version control markers of merge conflicts
" & checks for textura's not ok bandit errors
" if you want to force the write to succeed anyway, you still have that ability. This can be accomplished by issuing the write command with noautocmd.
" :noautocmd w
" Or,
" :noa w
function! RaiseExceptionForUnresolvedErrors()
    let s:file_name = expand('%:t')
    let s:conflict_line = search('\v^[<=>]{7}( .*|$)', 'nw')
    if s:conflict_line != 0
        throw 'Found unresolved conflicts in ' . s:file_name . ':' . s:conflict_line
    endif

    if &filetype == 'python'
        let s:file_name = expand('%:t')

        silent %yank p
        new
        silent 0put p
        silent $,$d
        silent %!pyflakes
        silent exe '%s/<stdin>/' . s:file_name . '/e'
        unlet! s:file_name

        let s:un_res = search('\(unable to detect \)\@<!undefined name', 'nw')
        if s:un_res != 0
            let s:message = 'Syntax error! ' . getline(s:un_res)
            bd!
            throw s:message
        endif

        let s:ui_res = search('expected an indented block', 'nw')
        if s:ui_res != 0
            let s:message = 'Syntax error! ' . getline(s:ui_res)
            bd!
            throw s:message
        endif

        let s:ui_res = search('unexpected indent', 'nw')
        if s:ui_res != 0
            let s:message = 'Syntax error! ' . getline(s:ui_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('invalid syntax', 'nw')
        if s:is_res != 0
            let s:message = 'Syntax error! ' . getline(s:is_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('unindent does not match any outer indentation level', 'nw')
        if s:is_res != 0
            let s:message = 'Syntax error! ' . getline(s:is_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('EOL while scanning string literal', 'nw')
        if s:is_res != 0
            let s:message = 'Syntax error! ' . getline(s:is_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('trailing comma not allowed without surrounding parentheses', 'nw')
        if s:is_res != 0
            let s:message = 'Syntax error! ' . getline(s:is_res)
            bd!
            throw s:message
        endif

        let s:is_res = search('problem decoding source', 'nw')
        if s:is_res != 0
            let s:message = 'pyflakes error! Check results manually! ' . getline(s:is_res)
            bd!
            throw s:message
        endif
        bd!


        let s:file_name = expand('%:t')
        silent %yank p
        new
        silent 0put p
        silent $,$d
        silent %!/home/alyssa.hirsh/virtualenvs/bandit/bin/bandit -
        silent exe '%s/<stdin>/' . s:file_name . '/e'
        unlet! s:file_name

        let s:is_res = search('^>> Issue:', 'nw')
        if s:is_res != 0
            let s:res_end = s:is_res + 2
            for item in getline(s:is_res, s:res_end)
                echohl ErrorMsg | echo item | echohl None
            endfor

            bd!
            throw 'Bandit Error'
        endif

        bd!
    endif
endfunction
autocmd BufWritePre * call RaiseExceptionForUnresolvedErrors()
