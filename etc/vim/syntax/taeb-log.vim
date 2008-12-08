" Vim syntax file
" Language:	TAEB logfiles
" Author:	Jesse Luehrs <doy at tozt dot net>
" Version:	20081207
" Copyright:	Copyright (c) 2008 Jesse Luehrs
" Licence:	You may redistribute this under the same terms as Vim itself

if exists("b:current_syntax")
  finish
endif

syn match   TAEBinfo    /^.\{-}\]/
            \ contains=TAEBturn,TAEBtime,TAEBmsgtype
syn match   TAEBtime    /.\{-}:/
            \ display nextgroup=TAEBmsgtype skipwhite contained
syn match   TAEBturn    /^<T\(-\|\d\+\)>/
            \ display nextgroup=TAEBtime skipwhite contained
syn match   TAEBmsgtype /\[[^]]\{-}\]/
            \ display contains=TAEBlevel,TAEBchannel contained
syn keyword TAEBlevel   DEBUG INFO NOTICE WARNING ERROR CRITICAL EMERGENCY
            \ contained
syn match   TAEBchannel /:\zs\w\+\ze\]/
            \ display contained

hi def link TAEBturn    Keyword
hi def link TAEBtime    Comment
hi def link TAEBlevel   Constant
hi def link TAEBchannel Special
hi def link TAEBmsgtype Type

let b:current_syntax = "taeb-log"
