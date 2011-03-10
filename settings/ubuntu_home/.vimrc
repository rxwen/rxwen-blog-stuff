set nocompatible
source $VIMRUNTIME/vimrc_example.vim
"source $VIMRUNTIME/mswin.vim
"behave mswin

" use quickfix window as cscope's output window
:set cscopequickfix=s-,g-,d-,c-,t-,e-,f-,i-

:set grepprg=grep\ -nrIE
nnoremap \gp :grep --include=* 

nnoremap \cn :cnext<CR> 
nnoremap \cp :cprevious<CR> 
nnoremap <C-W>t :tabnew<CR> 
" tcsh-style editing keys
:cnoremap <C-A> <Home>
:cnoremap <C-F> <Right>
:cnoremap <C-B> <Left>

syntax on
set nocompatible
set nu
colo evening
set nobackup
set ic 	"ignore case when search, to turn it off, run :set noic
set smartindent
set autoindent
set guioptions-=T 
"autocmd FileType c,cpp,h,asp,html set shiftwidth=4 | set tabstop=4 | set expandtab  
set shiftwidth=4 " set auto indent width to 4 when switch lines
set tabstop=4 " set indent width to 4
set expandtab " use spaces instead of tab 

autocmd BufNewFile *.py      0r ~/.vim/skeleton/py.skel
autocmd BufNewFile Android.mk 0r ~/.vim/skeleton/Android.mk.skel

" nmap // <ESC>^i//<ESC>

let cscopefiles_load=1
let cscopefiles_be=1
let cscopefiles_be_notify=10000

   if filereadable("cscope.files")
      if cscopefiles_load == 1
         let cscopefiles_list = ""
      endif

      let s:be_count = 0
      let s:be_add_next = 1
      let s:be_answed = 0

      for s:line in readfile("cscope.files","",)
         if !filereadable(s:line)
             continue
         endif 

         " add the cscope file list to string buffer
         if cscopefiles_load == 1
            let cscopefiles_list = cscopefiles_list . " " . s:line
         endif


         " add the cscope file list to buffer explorer
         if cscopefiles_be == 1
            let s:be_count = s:be_count+1

            if s:be_add_next == 0
               continue
            endif

            if s:be_answed == 0
		if s:be_count >= cscopefiles_be_notify
		   while 1
		      echo "The explore buffered file is more than " cscopefiles_be_notify "do you want load all y/n ?"
		      let s:be_answ = getchar()

		      if s:be_answ == 121 "y
                        let s:be_answed = 1
			 break
		      endif

		      if s:be_answ == 110 "n
                         let s:be_answed = 1
			 let s:be_add_next = 0
			 break                    
		      endif
		   endwhile
		endif
            endif

            if s:be_add_next == 1
               "execute "bad" . s:line
            endif
         endif
      endfor
   else
      let cscopefiles_load = 0
      let cscopefiles_be = 0

   endif


"nmap // <ESC>^i//<ESC>
vmap n y/<C-R>"<CR>

if exists("cscopefiles_list")
   vmap f y:execute "vimgrep " . @0 . cscopefiles_list <CR> :cw <CR>
else
   vmap f y:vimgrep <C-R>" **/*.h **/*.c **/*.cpp
endif

" integrate svn blame function   
" to use it, select desired code in visual mode then type gl
vmap gl :<C-U>!svn blame <C-R>=expand("%:p") <CR> \| sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>


" start fuzzyfinder mapping 
nmap \ff :FufFile<CR>
nmap \fb :FufBuffer<CR>
nmap \fd :FufDir<CR>
nmap \fma :FufBookmarkFileAdd<CR>
nmap \fmf :FufBookmarkFile<CR>
nmap \fmd :FufBookmarkDir<CR>
"nmap \fc :FufMruCmd<CR>
nmap \ft :FufTag<CR>
nmap \fj :FufJumpList<CR>
nmap \fq :FufQuickfix<CR>
nmap \fl :FufLine<CR>
nmap \fh :FufHelp<CR>
"let g:fuf_keyOpenTabpage = '<C-CR>'
" end fuzzyfind mapping
