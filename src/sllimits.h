/* sllimits.h */
/*
Copyright (C) 2004-2021,2022 John E. Davis

This file is part of the S-Lang Library.

The S-Lang Library is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

The S-Lang Library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
USA.
*/

#define USE_NEW_HASH_CODE	1

/* slstring.c: Size of the hash table used for strings (prime numbers) */
#define SLSTRING_HASH_TABLE_SIZE       140009  /* was 32327, 25013, 10007 */
/* Other large primes: 70001, 100003, 300007,... */
/* slang.c: The stack size grows dynamically from SLANG_INITIAL_STACK_LEN
 * in increments of SLANG_INITIAL_STACK_LEN up to a maximum size of
 * SLANG_MAX_STACK_LEN.
 */
#ifdef __MSDOS_16BIT__
# define SLANG_INITIAL_STACK_LEN        512
# define SLANG_MAX_STACK_LEN		1024
#else
# define SLANG_INITIAL_STACK_LEN	(2*1024)
# define SLANG_MAX_STACK_LEN		(1024*1024)
#endif

/* slang.c: This sets the size on the depth of function calls.
 * Note: The greater the recursion depth, the more likely it is to run
 * out of C runtime library stackspace.  The numbers below are conservative
 */
#ifdef __MSDOS_16BIT__
# define SLANG_MAX_RECURSIVE_DEPTH	50
#else
# if (defined(__WIN32__) || defined(__CYGWIN__))
#  define SLANG_MAX_RECURSIVE_DEPTH	500
# else
#  define SLANG_MAX_RECURSIVE_DEPTH	1500
# endif
#endif

/* slang.c: Size of the stack used for local variables */
#ifdef __MSDOS_16BIT__
# define SLANG_MAX_LOCAL_STACK		200
#else
# define SLANG_MAX_LOCAL_STACK		(10*SLANG_MAX_RECURSIVE_DEPTH)
#endif

/* slang.c: The size of the hash table used for local and global objects.
 * These should be prime numbers.
 */
#if USE_NEW_HASH_CODE
# define SLGLOBALS_HASH_TABLE_SIZE	2048
# define SLLOCALS_HASH_TABLE_SIZE	64
# define SLSTATIC_HASH_TABLE_SIZE	64
#else
# define SLGLOBALS_HASH_TABLE_SIZE	2909
# define SLLOCALS_HASH_TABLE_SIZE	73
# define SLSTATIC_HASH_TABLE_SIZE	73
#endif

/* Do not change this */
#define SL_MAX_TOKEN_LEN		254

/* Size of the keyboard buffer use by the ungetkey routines */
#ifdef __MSDOS_16BIT__
# define SL_MAX_INPUT_BUFFER_LEN	40
#else
# define SL_MAX_INPUT_BUFFER_LEN	1024
#endif

/* Maximum number of nested switch statements */
#define SLANG_MAX_NESTED_SWITCH		10

/* Size of the block stack (used in byte-compiling) */
#define SLANG_MAX_BLOCK_STACK_LEN	50

/* slfile.c: Max number of open file pointers */
#ifdef __MSDOS_16BIT__
# define SL_MAX_FILES			32
#else
# define SL_MAX_FILES			256
#endif

/* slarrfun.inc: Default value of the innerprod block size */
#define SLANG_INNERPROD_BLOCK_SIZE	29

#if !defined(__MSDOS_16BIT__)
# define SLTT_MAX_COLORS 0x8000       /* consistent with SLSMG_COLOR_MASK */
#else
/* #define SLTT_MAX_COLORS 0x8000 */  /* use slvideo.c default */
#endif

