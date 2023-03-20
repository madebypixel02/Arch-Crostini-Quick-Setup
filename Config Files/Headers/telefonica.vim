let s:asciiart = [
	\"   .,,,        .,,,.       ..,,.    ",
	\",(######(,  ./######(/   *(######(, ",
	\"(########/. *#########* ./########/.",
	\"*(#######*. .(#######(.  /#######(, ",
	\"  .,*/*.       ,*/*,.      .*//,.   ",
	\"               .,,,.                ",
	\"            ./#######/              ",
	\"            *#########*             ",
	\"            .(#######(.             ",
	\"              .,***,.               ",
	\"               .,,,.                ",
	\"            ./#######/              ",
	\"            *#########*             ",
	\"            .(#######/.             ",
	\"              .,***,.    Telefonica "
	\]




let s:start		= '/*'
let s:end		= '*/'
let s:fill		= '*'
let s:length	= 95
let s:margin	= 5
let s:logoheight = len(s:asciiart)
let s:height = s:logoheight + 4

let s:types		= {
			\'\.c$\|\.h$\|\.cc$\|\.hh$\|\.cpp$\|\.hpp$\|\.php\|\.java$':
			\['/*', '*/', '*'],
			\'\.htm$\|\.html$\|\.xml$\|\.Rmd$\|\.md$':
			\['<!--', '-->', '*'],
			\'\.js$':
			\['//', '//', '*'],
			\'\.tex$':
			\['%', '%', '*'],
			\'\.ml$\|\.mli$\|\.mll$\|\.mly$':
			\['(*', '*)', '*'],
			\'\.vim$\|\vimrc$':
			\['"', '"', '*'],
			\'\.R$\|\.r$\|\.py$':
			\['#', '#', '*'],
			\'\.el$\|\emacs$':
			\[';', ';', '*'],
			\'\.f90$\|\.f95$\|\.f03$\|\.f$\|\.for$':
			\['!', '!', '/']
			\}

function! s:filetype()
	let l:f = s:filename()

	let s:start	= '#'
	let s:end	= '#'
	let s:fill	= '*'

	for type in keys(s:types)
		if l:f =~ type
			let s:start	= s:types[type][0]
			let s:end	= s:types[type][1]
			let s:fill	= s:types[type][2]
		endif
	endfor

endfunction

function! s:ascii(n)
	return s:asciiart[a:n - 3]
endfunction

function! s:textline(left, right)
	let l:left = strpart(a:left, 0, s:length - s:margin * 2 - strlen(a:right))

	return s:start . repeat(' ', s:margin - strlen(s:start)) . l:left . repeat(' ', s:length - s:margin * 2 - strlen(l:left) - strlen(a:right)) . a:right . repeat(' ', s:margin - strlen(s:end)) . s:end
endfunction

function! s:line(n)
	if a:n == 1 || a:n == s:height " top and bottom line
		return s:start . ' ' . repeat(s:fill, s:length - strlen(s:start) - strlen(s:end) - 2) . ' ' . s:end
	elseif a:n == 2 || a:n == s:height - 1 " blank line
		return s:textline('', '')
	elseif a:n == s:height - 7 " filename
		return s:textline(s:filename(), s:ascii(a:n))
	elseif a:n == s:height - 5 " author
		return s:textline("By: " . s:user() . " <" . s:mail() . ">", s:ascii(a:n))
	elseif a:n == s:height - 3 " created
		return s:textline("Created: " . s:date() . " by " . s:user(), s:ascii(a:n))
	elseif a:n == s:height - 2 " updated
		return s:textline("Updated: " . s:date() . " by " . s:user(), s:ascii(a:n))
	else " empty with ascii
		return s:textline('', s:ascii(a:n))
	endif
endfunction

function! s:user()
	if exists('g:user42')
		return g:user42
	endif
	let l:user = "T740907"
	if strlen(l:user) == 0
		let l:user = "marvin"
	endif
	return l:user
endfunction

function! s:mail()
	if exists('g:mail42')
		return g:mail42
	endif
	let l:mail = "alejandro.perezbueno@telefonica.com"
	if strlen(l:mail) == 0
		let l:mail = "marvin@42.fr"
	endif
	return l:mail
endfunction

function! s:filename()
	let l:filename = expand("%:t")
	if strlen(l:filename) == 0
		let l:filename = "< new >"
	endif
	return l:filename
endfunction

function! s:date()
	return strftime("%Y/%m/%d %H:%M:%S")
endfunction

function! s:insert()
	let l:line = s:height

	" empty line after header
	call append(0, "")

	" loop over lines
	while l:line > 0
		call append(0, s:line(l:line))
		let l:line = l:line - 1
	endwhile
endfunction

function! s:update()
	call s:filetype()
	if getline(s:height - 2) =~ s:start . repeat(' ', s:margin - strlen(s:start)) . "Updated: "
		if &mod
			call setline(s:height - 2, s:line(s:height - 2))
		endif
		call setline(s:height - 7, s:line(s:height - 7))
		return 0
	endif
	return 1
endfunction

function! s:telefonica()
	if s:update()
		call s:insert()
	endif
endfunction

" Bind command and shortcut
command! Telefonica call s:telefonica ()
map <F5> :Telefonica<CR>
autocmd BufWritePre * call s:update ()
