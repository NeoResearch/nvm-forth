\ FORTH implementation of NeoVM 2.x (Neo Blockchain Virtual Machine)
\ fast tutorial on forth: https://learnxinyminutes.com/docs/forth
\ https://yosefk.com/blog/my-history-with-forth-stack-machines.html
\ https://www.complang.tuwien.ac.at/forth/gforth/Docs-html/Characters-and-Strings-Tutorial.html
\ -----------------------------------------------------------
\ usage: online application https://neoresearch.io/nvm-learn/
\ locally on linux you can install gforth (apt install gforth)
\ however, FORTH syntax is not standard for both interpreters
\ this is meant to work only on the web application above
\ -----------------------------------------------------------

\ ================
\ define constants
\ ================

\ create empty bytearray
\variable empty 0 cells allot 
\ pushes empty bytearray to stack
\: push0 empty @ ;
\ for now, pushing ZERO instead of empty array... TODO: improve this
: push0 0 ;                          \ 0x00
: pushf push0 ;

\ push value -1 on main stack
: pushm1 -1 ;                        \ 0x4f
\ unused
\                                    \ 0x50                                       
\ push value 1 on main stack
: push1 1 ;                          \ 0x51
\ push value 1 on main stack
: pusht push1 ;                      \ 0x51
\ push value 2 on main stack
: push2 2 ;                          \ 0x52
\ push value 3 on main stack
: push3 3 ;                          \ 0x53
\ push value 4 on main stack
: push4 4 ;                          \ 0x54
\ push value 5 on main stack
: push5 5 ;                          \ 0x53
\ push value 6 on main stack
: push6 6 ;                          \ 0x53
\ push value 7 on main stack
: push7 7 ;                          \ 0x53
\ push value 8 on main stack
: push8 8 ;                          \ 0x53
\ push value 9 on main stack
: push9 9 ;                          \ 0x59
\ push value 10 on main stack
: push10 10 ;                        \ 0x5a
\ push value 11 on main stack
: push11 11 ;                        \ 0x5b
\ push value 12 on main stack
: push12 12 ;                        \ 0x5c
\ push value 13 on main stack
: push13 13 ;                        \ 0x5d
\ push value 14 on main stack
: push14 14 ;                        \ 0x5e
\ push value 15 on main stack
: push15 15 ;                        \ 0x5f
\ push value 16 on main stack
: push16 16 ;                        \ 0x60


\ ===========
\ control ops
\ ===========
\ nop: no operation
: nop ;                              \ 0x61

\ skip jumps, skip calls

\ skip ret

\ skip appcals, syscalls, tail call


\ ==========
\ stack ops
\ ==========

\ note: using return stack (rstack) as alternative stack. perhaps better using another software stack

\ duplicate data from alternative stack (could be `fromaltstack dup toaltstack`)
: dupfromaltstack r@ ;               \ 0x6a

\ move data to alternative stack
: toaltstack >r ;                    \ 0x6b

\ move data from alternative stack
: fromaltstack r> ;                  \ 0x6c

\ The item n back in the main stack is removed.
: xdrop roll drop ;                  \ 0x6d

\  The item n back in the main stack in swapped with top stack item.
\        XSWAP = 0x72 (requires loop/if)

\ The item on top of the main stack is copied and inserted to the position n in the main stack.
\        XTUCK = 0x73, (requires loop/if)

\ Puts the number of stack items onto the stack.
\ depth native defined (opcode 0x74)

\ Removes the top stack item.
\ drop native defined (opcode 0x75)

\ Duplicates the top stack item.
\ dup native defined (opcode 0x76)

\ Removes the second-to-top stack item.
\ nip native defined (opcode 0x77)

\ Copies the second-to-top stack item to the top.
\ over native defined (opcode 0x78)

\ The item n back in the stack is copied to the top.
\ pick native defined (opcode 0x79)

\ The item n back in the stack is moved to the top.
\ roll native defined (opcode 0x7a)

\ The top three items on the stack are rotated to the left.
\ rot native defined (opcode 0x7b)

\ The top two items on the stack are swapped.
\ swap native defined (opcode 0x7c)

\ The item at the top of the stack is copied and inserted before the second-to-top item.
\ tuck native defined (opcode 0x7d)

\ ==========================
\ begin arithmetic operators

\ inc 0x8b (defined after add)
\ dec 0x8c (defined after sub)

\ sign 8d (IF)

\ negate 8f (IF)

\ abs 90 (IF)

\ not 91 (IF)

\ nz 92 (IF)

\ add values on main stack
: add + ;                        \ 0x93

\ subtract values on main stack
: sub - ;                        \ 0x94

\ adds 1 to the input (defined here because of add)
: inc 1 add ;                    \ 0x8b

\ subtracts 1 from the input (defined here because of sub)
: dec 1 sub ;                    \ 0x8c

\ multiply values on main stack
: mul * ;                        \ 0x95

\ a is divided by b
: div / ;                        \ 0x96

\ mod (native)                   \ 0x97

\ shl (c# bigint) 0x98

\ shr (c# bigint) 0x99

\ booland (IF) 0x9a

\ boolor (IF) 0x9b

\ Returns 1 if the numbers are equal, 0 otherwise (note that forth true is -1)
: numequal = -1 mul ;              \ 0x9c

\ 9d reserved ?

\ Returns 1 if the numbers are not equal, 0 otherwise. (note that forth true is -1)
: numnotequal = 1 add ;            \ 0x9e

\ Returns 1 if a is less than b, 0 otherwise. (note that forth true is -1)
: lt < -1 mul ;            \ 0x9f

\ Returns 1 if a is greater than b, 0 otherwise. (note that forth true is -1)
: gt > -1 mul ;            \ 0xa0

\ lte (IF ? OR? <= ?)   \ 0xa1

\ gte (IF ? OR? >= ?)   \ 0xa2

\ Returns the smaller of a and b. \ 0xa3
\ min (native)

\ Returns the larger of a and b. \ 0xa4
\ max (native)

\ Returns 1 if x is within the specified range (left-inclusive), 0 otherwise.
\ WITHIN = 0xA5,

\ ====================
variable nvmarraytest            \ single global for array tests (warming-up var system)

\ arraysize is position zero of array
: arraysize push0 add @ ;                                          \ 0xc0

\ pack (opcode 0xc1) - presented in a few lines after

\ unpack (opcode 0xc2) - not implemented, yet

\ An input index n (or key) and an array (or map) are taken from main stack. Element array[n] (or map[n]) is put on top of the main stack.
: pickitem cells push1 add add @ ;                                 \ 0xc3
\ 1600 0 pickitem -> 1600[1]
        \ PICKITEM = 0xC3,
\        /// <summary>
\        /// A value v, index n (or key) and an array (or map) are taken from main stack. Attribution array[n]=v (or map[n]=v) is performed.
\        /// </summary>
\ SETITEM = 0xC4,
: setitem swap push1 add rot add ! ;                               \ 0xc4
\ 1600 0 10 -> 1600[1] = 10

\ newarray  (alloc n spaces + 1 for count)
: newarray dup here swap push1 add cells allot dup rot swap ! ;    \ 0xc5

\ pack (using `do loop` in return stack, may not work on gforth)    \0xc1 (after newarray/setitem)
: pack dup newarray toaltstack push0 do fromaltstack dupfromaltstack swap dup toaltstack rot setitem loop fromaltstack ;
\ warning: `0 pack` may break the FORTH loop

\ bye

\ clean page (command implemented manually)
page