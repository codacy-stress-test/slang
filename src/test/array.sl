() = evalfile ("./inc.sl");

testing_feature ("array functions");

% Ensure that this mechanism of array creation is supported.
$1 = Short_Type[10, 20];
$2 = _typeof ($1)[3,4];
if (typeof ($2) != Array_Type)
  failed ("_typeof(X)[] failed to create an array");
if (_typeof($2) != Short_Type)
  failed ("_typeof(X)[] failed to create an array of the proper type");
if ((array_shape ($2)[0] != 3) or (array_shape($2)[1] != 4))
  failed ("typeof(X)[] failed to create an array of the proper shape");

private define eqs (a, b)
{
   return _eqs(a,b);
#iffalse
   variable len;
   len = length (a);
   if (len != length (b))
     return 0;

   len == length (where (a == b));
#endif
}

private define array_dims (a)
{
   variable dims;
   (dims,,) = array_info (a);
   if (0 == eqs (dims, array_shape (a)))
     failed ("array_shape failed");

   return dims;
}

private define neqs (a, b)
{
   not (eqs (a, b));
}

private variable A = [0:23];

private variable B = transpose(A);
private variable dims;

(dims,,) = array_info (B);
if ((dims[0] != 1)
    or (dims[1] != 24))
  failed ("transpose ([0:23], found %S)", B);

reshape (A, [2,3,4]);

%   0  1  2  3
%   4  5  6  7   = A[0,*,*]
%   8  9 10 11
%
%  12 13 14 14
%  16 17 18 19   = A[1,*,*]
%  20 21 22 23
%
if ((A[0,0,0] != 0)
    or (A[0,0,1] != 1)
    or (neqs (A[0,0,[:]], [0:3]))
    or (neqs (A[0,1,[:]], [4:7]))
    or (neqs (A[0,2,[:]], [8:11]))
    or (neqs (A[1,0,[:]], [12:15]))
    or (neqs (A[1,1,[:]], [16:19]))
    or (neqs (A[1,2,[:]], [20:23]))) failed ("reshape");

if (A[0,-1, -1] != 11) failed ("A[0,-1,-1]");
if (length (A[0,-1, [0:-1]])) failed ("length A[0,-1,[0:-1]]");
if (length (A[0,-1, [-1:3]]) != 5) failed ("length A[0,-1,[-1:3]]");
#iffalse
if (neqs(array_shape(A[[0:-1],*,*]), [0,3,4])
    || neqs(array_shape(A[*,[0:-1],*]), [2,0,4])
    || neqs(array_shape(A[*,*,[0:-1]]), [2,3,0])
    || neqs(array_shape(A[*,[0:-1],[0:-1]]), [2,0,0])
    || neqs(array_shape(A[[0:-1],*,[0:-1]]), [0,3,0])
    || neqs(array_shape(A[[0:-1],[0:-1],*]), [0,0,4])
    || neqs(array_shape(A[[0:-1],[0:-1],[0:-1]]), [0,0,0]))
  failed ("indexing mult-dim array with [0:-1]");
#endif
try
{
   () = A[0,-1,[-7:0]];
   failed ("A[0],-1,[-5:0]");
}
catch IndexError;

private define test_transpose_for_all_types ()
{
   foreach (Util_Arith_Types)
     {
	variable t = ();
	variable b = transpose (typecast (A, t));
	if ((b[0,0,0] != 0)
	    or (b[1,0,0] != 1)
	    or (neqs (b[[:],0,0], [0:3]))
	    or (neqs (b[[:],1,0], [4:7]))
	    or (neqs (b[[:],2,0], [8:11]))
	    or (neqs (b[[:],0,1], [12:15]))
	    or (neqs (b[[:],1,1], [16:19]))
	    or (neqs (b[[:],2,1], [20:23])))
	  failed ("transpose %S array", t);
     }
}

if (length ([8198:8192:8192]) != 0)
  failed ("length ([8198:8192:8192])");

if (length ([8198.0:8192.0:8192]) != 0)
  failed ("length ([8198.0:8192.0:8192])");

% Test for memory leak
B = transpose (A);
loop (3) B = transpose (B);
B = 0;

% Try on a string array
A = [0:23];
variable S = String_Type[length (A)];
foreach (A)
{
   variable i = ();
   S[i] = string (i);
}

variable T = @S;
reshape (S, [2,3,4]);

if ((S[0,0,0] != T[0])
    or (S[0,0,1] != T[1])
    or (neqs (S[0,0,*], T[[0:3]]))
    or (neqs (S[0,1,*], T[[4:7]]))
    or (neqs (S[0,2,*], T[[8:11]]))
    or (neqs (S[1,0,*], T[[12:15]]))
    or (neqs (S[1,1,*], T[[16:19]]))
    or (neqs (S[1,2,*], T[[20:23]]))) failed ("reshape string array");

S = transpose (S);

if ((S[0,0,0] != T[0])
    or (S[1,0,0] != T[1])
    or (neqs (S[*,0,0], T[[0:3]]))
    or (neqs (S[*,1,0], T[[4:7]]))
    or (neqs (S[*,2,0], T[[8:11]]))
    or (neqs (S[*,0,1], T[[12:15]]))
    or (neqs (S[*,1,1], T[[16:19]]))
    or (neqs (S[*,2,1], T[[20:23]]))) failed ("transpose string array");

S = ["", "1", "12", "123", "1234", "12345"];
S = array_map (Int_Type, &strlen, S);
if (neqs (S, [0:5])) failed ("array_map 1");

S = ["", "1", "12", "123", "1234", "12345"];
variable SS = S + S;
if (neqs (SS, array_map (String_Type, &strcat, S, S))) failed ("array_map 2");

SS = S + "--end";
if (neqs (SS, array_map (String_Type, &strcat, S, "--end"))) failed ("array_map 3");

try
{
   SS = Long_Type[10000,10000,10000,10000,10000,10000];
}
catch IndexError;

private define array_map2_func ()
{
   variable args = __pop_list (_NARGS-1);
   variable f = ();
   variable r1, r2;
   (r1, r2) = (@f)(__push_list(args));
   return {r1, r2};
}

private define array_map2 ()
{
   variable args = __pop_list (_NARGS-3);
   variable ret1, ret2, f;
   (ret1, ret2, f) = ();
   variable rlist = array_map (List_Type, &array_map2_func, f, __push_list(args));
   %rlist is an array of lists
   variable n = length (rlist);
   variable t0 = typeof (rlist[0][0]), t1 = typeof (rlist[0][1]);
   variable a0 = t0[n], a1 = t1[n];
   _for (0, n-1, 1)
     {
	variable i = ();
	a0[i] = rlist[i][0];
	a1[i] = rlist[i][1];
     }
   return a0, a1;
}

private define sum_and_diff (x, y)
{
   return x+y, x-y;
}

private define count_func (x, ref)
{
   @ref++;
}

private define test_array_mapN ()
{
   variable s, d, s1, d1, x, y;
   x = [1:10], y = [1:10];
   (s,d) = array_map (Double_Type, Double_Type, &sum_and_diff, x, y);
   (s1, d1) = array_map2 (Double_Type, Double_Type, &sum_and_diff, x, y);
   if (neqs (s1,s) || neqs (d1, d))
     failed ("array_map with 2 returns test 1");

   x = [1:10], y = 1.0;
   (s,d) = array_map (Double_Type, Double_Type, &sum_and_diff, x, y);
   (s1, d1) = array_map2 (Double_Type, Double_Type, &sum_and_diff, x, y);
   if (neqs (s1,s) || neqs (d1, d))
     failed ("array_map with 2 returns test 2");

   y = [1:10], x = 1.0;
   (s,d) = array_map (Double_Type, Double_Type, &sum_and_diff, x, y);
   (s1, d1) = array_map2 (Double_Type, Double_Type, &sum_and_diff, x, y);
   if (neqs (s1,s) || neqs (d1, d))
     failed ("array_map with 2 returns test 3");

   x = [1:10];
   s = array_map (Double_Type, &sin, x);
   s1 = array_map (Void_Type, Double_Type, &sin, x);
   if (neqs (s1,s))
     failed ("array_map with 1 void return test 1");
   s1 = array_map (Double_Type, Void_Type, &sin, x);
   if (neqs (s1,s))
     failed ("array_map with 1 void return test 2");

   x = [1:10];
   y = 0;
   array_map (&count_func, x, &y);
   if (y != length(x))
     failed ("array_map with implicit void");

   x = [1:10];
   y = 0;
   array_map (Void_Type, &count_func, x, &y);
   if (y != length(x))
     failed ("array_map with explicit void");
}

test_array_mapN ();

#ifexists Double_Type
S = [1:20:0.1];
if (neqs (sin(S), array_map (Double_Type, &sin, S))) failed ("array_map 4");

S = [1:20:0.1];
variable Sin_S = Double_Type[length(S)];
private define void_sin (x, i)
{
   Sin_S[i] = sin (x);
}
array_map (Void_Type, &void_sin, S, [0:length(S)-1]);
if (neqs (sin(S), Sin_S))
  failed ("array_map Void_Type");
#endif

$1 = array_map (Int_Type, &strlen, String_Type[0]);
if ((length ($1) != 0) or (_typeof ($1) != Int_Type))
  failed ("array_map String_Type[0]");

$1 = array_map (String_Type, &strcat, "Hello", String_Type[0]);
if ((length ($1) != 0) or (_typeof ($1) != String_Type))
  failed ("array_map (Hello, String_Type[0]");

try
{
   $1 = array_map (String_Type, &strcat, ["Hello"], String_Type[0]);
   failed ("array_map ([Hello], String_Type[0] did not generate an exception");
}
catch TypeMismatchError;

private define function_returning_NULL_or_string (x) { x == 0 ? NULL : "!0"; }
$1 = array_map (String_Type, &function_returning_NULL_or_string, [-1:1]);
if (neqs ($1, ["!0", NULL, "!0"]))
  failed ("array_map putting NULL into String_Type array");

% Indexing of 7d array
if (31 != _reshape ([31], [1,1,1,1,1,1,1])[0,0,0,0,0,0,0])
  failed ("reshape of 7d array");

A=[1:24];
B = A[*];
if (neqs(A,B))
  failed("A[*] 1");
B = (A+1)-1;
if (neqs (A, B))
  failed ("(A+1)-1");
B = A[*];
if (neqs(A,B))
  failed("A[*] 2");
A = 3; if (typeof (A[*]) != Array_Type) failed ("typeof A[*]");

% Check indexing with negative subscripts
S = [0:10];
if (S[-1] != 10) failed ("[-1]");
#iffalse
% Old, broken semantics
if (length (S[[-1:3]])) failed ("[-1:3]");
if (neqs(S[[-1:0:-1]], [10:0:-1])) failed ("[-1:0:-1]");
if (neqs(S[[0:-1]], S)) failed ("[0:-1]");
if (neqs(S[[3:-1]], [3:10])) failed ([3:-1]);
if (length (S[[0:-1:-1]])) failed ("[0:-1:-1]");   %  first to last by -1
if (neqs(S[[0:]], S)) failed ("[0:]");
if (neqs(S[[:-1]], S)) failed ("[:-1]");
#else
% New semantics
if (length (S[[-1:3]]) != 5) failed ("[-1:3]");
if (length(S[[-1:0:-1]])) failed ("[-1:0:-1]");
if (neqs(S[[-1:1]], [S[-1],S[0],S[1]])) failed ("[-1:1]");
if (neqs(S[[0:-1:-1]], [S[0],S[-1]])) failed ("[0:-1:-1]");
if (neqs(S[[-2:2]], [S[-2],S[-1],S[0],S[1],S[2]])) failed ([-2:2]);
if (length (S[[0:-1:1]])) failed ("[0:-1:1]");
if (neqs(S[[0:]], S)) failed ("[0:]");
if (neqs(S[[-11:-1]], S)) failed ("[-10:-1]");

if (length (S[[:-1]]) != length(S)) failed ("S[:-1]");
if (neqs(S[[:-1]], S)) failed ("[0:-1]");
if (neqs(S[[-1::-1]], [10:0:-1])) failed ("S[-1::-1]");
if (neqs(S[[3:]], [3:10])) failed ([3:]);
if (neqs(S[[-3:]], S[[8:10]])) failed ("[-3:]");
if (neqs(S[[-3::-1]], S[[8:0:-1]])) failed ("[-3:]");
if (neqs(S[[:-3]], S[[0:8]])) failed ("[:-3]");
if (neqs(S[[:3:-1]], S[[10:3:-1]])) failed ("[:-1]");
if (neqs(S[[::-1]], S[[10:0:-1]])) failed ("[::-1]");
if (neqs(S[[:]], S[[0:10]])) failed ("[:]");
if (neqs(S[[::1]], S[[0:10]])) failed ("[::1]");

%  This is very useful in practice.  Make sure it does not break.
if (length(S[[length(S):]])) failed("[length(S):]");

#endif

A = [0:20];
A[[-1,-2]] = 0;
if (neqs (A[[0:18]], [0:18]))
  failed ("A[[-1,-2]] = 0");
if ((A[19] != 0) or (A[20] != 0))
  failed ("A[[-1,-2]] = 0");

S = Int_Type[0];
if (length (S) != 0) failed ("Int_Type[0]");
if (neqs (S, S[[0:-1]])) failed ("Int_Type[0][[0:-1]]");

S = bstring_to_array ("hello");
if ((length (S) != 5)
    or (typeof (S) != Array_Type)) failed ("bstring_to_array");
if ("hello" != array_to_bstring (S)) failed ("array_to_bstring");

A = ['a':'z'];
foreach (A)
{
   $1 = ();
   if (A[$1 - 'a'] != $1)
     failed ("['a':'z']");
}

define check_result (result, answer, op)
{
   if (neqs (answer, result))
     failed ("Binary operation `%s' failed", op);
}

private define check_bin_result (a, op, b, ans, opstr)
{
   variable types = [Char_Type, UChar_Type, Short_Type, UShort_Type,
		     Int_Type, UInt_Type, Long_Type, ULong_Type];

   variable atype, btype;
   foreach atype (types)
     {
	variable aa = typecast (a, atype);
	foreach btype (types)
	  {
	     variable bb = typecast (b, btype);
	     check_result ((@op)(aa, bb), ans, "$atype $opstr $btype"$);
	  }
     }
}

check_bin_result ([1,2], &_op_plus, [3,4], [4,6],"+");
check_bin_result (1, &_op_plus, [3,4], [4,5],"+");
check_bin_result ([3,4], &_op_plus, 1, [4,5],"+");

check_bin_result ([1,2], &_op_minus, [3,4], [-2,-2],"-");
check_bin_result (1, &_op_minus, [3,4], [-2,-3],"-");
check_bin_result ([3,4], &_op_minus, 1, [2,3],"-");

check_bin_result ([1,2], &_op_times, [3,4], [3,8], "*");
check_bin_result (1, &_op_times, [3,4], [3,4], "*");
check_bin_result ([3,4], &_op_times, 1, [3,4], "*");

check_bin_result ([12,24], &_op_divide, [3,4], [4,6],"/");
check_bin_result (12, &_op_divide, [3,4], [4,3],"/");
check_bin_result ([3,4], &_op_divide, 1, [3,4],"/");

check_bin_result ([1,2], &_op_mod, [3,4], [1,2],"mod");
check_bin_result (3, &_op_mod, [3,2], [0,1],"mod");
check_bin_result ([3,4], &_op_mod, 4, [3,0],"mod");

check_bin_result ([1,2], &_op_eqs, [3,2], [0,1],"==");
check_bin_result (3, &_op_eqs, [3,4], [1,0],"==");
check_bin_result ([3,4], &_op_eqs, 1, [0,0],"==");

check_bin_result ([1,2], &_op_neqs, [3,2], [1,0],"!=");
check_bin_result (3, &_op_neqs, [3,4], [0,1],"!=");
check_bin_result ([3,4], &_op_neqs, 1, [1,1],"!=");

check_bin_result ([1,2], &_op_gt, [3,2], [0,0],">");
check_bin_result (1, &_op_gt, [3,4], [0,0],">");
check_bin_result ([3,4], &_op_gt, 1, [1,1],">");

check_bin_result ([1,2], &_op_ge, [3,2], [0,1],">=");
check_bin_result (1, &_op_ge, [3,4], [0,0],">=");
check_bin_result ([3,4], &_op_ge, 1, [1,1],">=");

check_bin_result ([1,2], &_op_lt, [3,2], [1,0],"<");
check_bin_result (1, &_op_lt, [3,4], [1,1],"<");
check_bin_result ([3,4], &_op_lt, 1, [0,0],"<");

check_bin_result ([1,2], &_op_le, [3,2], [1,1],"<=");
check_bin_result (1, &_op_le, [3,4], [1,1],"<=");
check_bin_result ([3,4], &_op_le, 1, [0,0],"<=");
#ifexists Double_Type
check_bin_result ([1,2], &_op_pow, [3,2], [1,4],"^");
check_bin_result (1, &_op_pow, [3,4], [1,1],"^");
check_bin_result ([3,4], &_op_pow, 1, [3,4],"^");
check_bin_result ([3,4], &_op_pow, 0, [1,1],"^");
#endif
check_bin_result ([1,2], &_op_or, [3,2], [1,1],"or");
check_bin_result (1, &_op_or, [3,4], [1,1],"or");
check_bin_result ([0,1], &_op_or, 1, [1,1],"or");

check_bin_result ([1,2], &_op_and, [3,2], [1,1],"and");
check_bin_result (1, &_op_and, [0,4], [0,1],"and");
check_bin_result ([3,4], &_op_and, 0, [0,0],"and");

check_bin_result ([1,2], &_op_band, [3,2], [1,2],"&");
check_bin_result (1, &_op_band, [3,4], [1,0],"&");
check_bin_result ([3,4], &_op_band, 1, [1,0],"&");

check_bin_result ([1,2], &_op_bor, [3,2], [3,2],"|");
check_bin_result (1, &_op_bor, [3,4], [3,5],"|");
check_bin_result ([3,4], &_op_bor, 1, [3,5],"|");

check_bin_result ([1,2], &_op_xor, [3,2], [2,0],"xor");
check_bin_result (1, &_op_xor, [3,4], [2,5],"xor");
check_bin_result ([3,4], &_op_xor, 1, [2,5],"xor");

check_bin_result ([1,2], &_op_shl, [3,2], [8,8],"shl");
check_bin_result (1, &_op_shl, [3,4], [8,16],"shl");
check_bin_result ([3,4], &_op_shl, 1, [6,8],"shl");

check_bin_result ([1,4], &_op_shr, [3,1], [0,2],"shr");
check_bin_result (8, &_op_shr, [3,4], [1,0],"shr");
check_bin_result ([3,4], &_op_shr, 1, [1,2],"shr");

% Test __tmp optimizations
private define test_tmp ()
{
   variable x = [1:100];
   x = 1*__tmp(x)*1 + 1;
   if (neqs (x), [2:101])
     failed ("__tmp optimizations");
}

private define ones ()
{
   variable a;

   a = __pop_args (_NARGS);
   return @Array_Type (Integer_Type, [__push_args (a)]) + 1;
}

variable X = ones (5, 10);

(dims,,) = array_info (X);
if ((dims[0] != 5) or (dims[1] != 10))
  failed ("ones dims: [%S,%S]", dims[0], dims[1]);
if (length (where (X != 1)))
  failed ("ones 1");

define test_assignments (x, i, a)
{
   variable y, z;

   y = @x; z = @x; y[i] += a; z[i] = z[i] + a; check_result (y, z, "[]+=");
   y = @x; z = @x; y[i] -= a; z[i] = z[i] - a; check_result (y, z, "[]-=");
   y = @x; z = @x; y[i] /= a; z[i] = z[i] / a; check_result (y, z, "[]/=");
   y = @x; z = @x; y[i] *= a; z[i] = z[i] * a; check_result (y, z, "[]*=");

   y = @x; z = @x; y[i]++; z[i] = z[i] + 1; check_result (y, z, "[]++");
   y = @x; z = @x; y[i]--; z[i] = z[i] - 1; check_result (y, z, "[]--");
}

test_assignments ([1:10], 3, 5);
test_assignments ([1:10], [3], 5);
test_assignments ([1:10], [1,3,5], 5);
test_assignments ([1:10], [0:4], 5);
test_assignments ([1:10], [0:], 5);
test_assignments ([1:10], [:], 5);
test_assignments ([1:10], [*], 5);

% Test semi-open intervals
define test_semiopen (a, b, dx, n)
{
   variable last, first;
   variable aa = [a:b:dx];

   if (length (aa) != n)
     failed ("test_semiopen (%S,%S,%S,%S): length==>%d", a, b, dx, n, length(aa));

   if (n == 0)
     return;

   first = aa[0];
   if (first != a)
     failed ("test_semiopen (%S,%S,%S,%S): first", a, b, dx, n);

   last = a[-1];
   if (dx > 0)
     {
	if (last >= b)
	  failed ("test_semiopen (%S,%S,%S,%S): last", a, b, dx, n);
     }
   else if (last <= b)
	  failed ("test_semiopen (%S,%S,%S,%S): last", a, b, dx, n);
}
#ifexists Double_Type
test_semiopen (1.0, 10.0, 1.0, 9);
test_semiopen (1.0, 1.0, 12.0, 0);
test_semiopen (1.0, 1.2, -1.0, 0);
test_semiopen (1.0, 0.0, -1.0, 1);
test_semiopen (1.0, -0.0001, -1.0, 2);
#endif

private define test_inline_array (a, type)
{
   if (_typeof (a) != type)
     failed ("test_inline_array: %S is not %S type", a, type);
}

test_inline_array ([1,2,3], Int_Type);
test_inline_array ([1L,2L,3L], Long_Type);
test_inline_array ([1h,2h,3h], Short_Type);
#ifexists Double_Type
test_inline_array ([1f, 0, 0], Float_Type);
test_inline_array ([1f, 0.0, 0h], Double_Type);
#endif
#ifexists Complex_Type
test_inline_array ([1f, 0.0, 0i], Complex_Type);
test_inline_array ([1i, 0h, 0i], Complex_Type);
test_inline_array ([0h, 0i], Complex_Type);
test_inline_array ([0i, 0i], Complex_Type);
#endif
test_inline_array (["a", "b"], String_Type);

A = String_Type[10];
A[*] = "a";
if ("aaaaaaaaaa" != strjoin (A, ""))
  failed ("A[*]");
A[5] = NULL;
if ((A[5] != NULL)
    or ("aaaaaaaaa" != strjoin (A[[0,1,2,3,4,6,7,8,9]], "")))
  failed ("A[5] != NULL");

A[1] = NULL;
if ((length(where(_isnull(A))) != 2)
     or (where (_isnull(A))[0] != 1)
     or (where (_isnull(A))[1] != 5))
  failed ("_isnull: %S", where(_isnull(A))[1] != 5);

A = NULL; if (_isnull(A) == 0) failed ("_isnull(NULL)");
A = Null_Type[10];
ifnot (all(_isnull (A))) failed ("_isnull(Null_Type[10])");
if (length (_isnull(A)) != length(A)) failed ("length _isnull(Null_Type[10])");

A = String_Type[10];
A[*] = "a";
if ("aaaaaaaaaa" != strjoin (A, ""))
  failed ("A[5]=a");
A[[3,7]] = NULL;
if ((A[3] != NULL) or (A[7] != NULL)
    or ("aaaaaaaa" != strjoin (A[[0,1,2,4,5,6,8,9]], "")))
  failed ("A[3,7]=NULL");

A = String_Type[10];
A[*] = "a";
A[1] = NULL;
if (length (where (A != String_Type[10])) != 9)
  failed ("A != String_Type[10]");



private define test_indexing_with_1_index ()
{
   variable n = 10;
   variable a = Double_Type[n,n];
   variable i = [0:n*n-1:n+1];
   variable ai = a[i];
   if (0 == _eqs (ai, a[[0:n*n-1:n+1]]))
     failed ("a[i] != a[[0:n*n-1:n+1]]");
   i = [0,11,22,33,44,55,66,77,88,99];
   if (0 == _eqs (ai, a[i]))
     failed ("ai != a[i]");
   ai = [a[0,0],a[1,1],a[2,2],a[3,3],a[4,4],
	 a[5,5],a[6,6],a[7,7],a[8,8],a[9,9]];
   if (0 == _eqs (ai, a[i]))
     failed ("[a[0,0],...,a[9,9]] != a[i]");

   reshape (a, [n*n]);
   i = -1;
   if ((a[-1] != a[i]) || (a[-1] != a[i+length(a)]))
     failed ("a[i] != a[%d], with i==%d", i, i);

   i = -2;
   if ((a[-2] != a[i]) || (a[-2] != a[i+length(a)]))
     failed ("a[i] != a[%d], with i==%d", i, i);

   i = 1;
   if ((a[1] != a[i]) || (a[1] != a[i-length(a)]))
     failed ("a[i] != a[%d], with i==%d", i, i);
}
test_indexing_with_1_index ();

private define test_index_arrays ()
{
   foreach (Util_Arith_Types)
     {
	variable s = ();
	variable x = typecast ([1:10], s);
	variable y = typecast ([1,3,5,7,9], s);
	variable i = [0::2];
	foreach (Util_Arith_Types)
	  {
	     variable t = ();
	     if (1 != __is_numeric(t))
	       continue;
	     variable ii = typecast (i, t);
	     ifnot (_eqs (y, x[i]))
	       failed ("get with index array of type %S", t);
	     variable z = Int_Type[10];
	     z[ii] = y;
	     ifnot (_eqs (y, z[ii]))
	       failed ("put with index array of type %S", t);
	  }
     }
}
test_index_arrays ();

% Test array summing operations
#ifexists Double_Type
private define compute_sum (a, n)
{
   variable s = 0;
   variable b;
   variable i, j, k;
   variable dims;

   (dims,,) = array_info (a);
   if (n == 0)
     {
	b = Double_Type[dims[1],dims[2]];
	for (i = 0; i < dims[1]; i++)
	  {
	     for (j = 0; j < dims[2]; j++)
	       {
		  for (k = 0; k < dims[n]; k++)
		    b[i,j] += a[k,i,j];
	       }
	  }
	return b;
     }
   if (n == 1)
     {
	b = Double_Type[dims[0],dims[2]];
	for (i = 0; i < dims[0]; i++)
	  {
	     for (j = 0; j < dims[2]; j++)
	       {
		  for (k = 0; k < dims[n]; k++)
		    b[i,j] += a[i,k,j];
	       }
	  }
	return b;
     }
   if (n == 2)
     {
	b = Double_Type[dims[0],dims[1]];
	for (i = 0; i < dims[0]; i++)
	  {
	     for (j = 0; j < dims[1]; j++)
	       {
		  for (k = 0; k < dims[n]; k++)
		    b[i,j] += a[i,j,k];
	       }
	  }
	return b;
     }

   b = 0.0;
   for (i = 0; i < dims[0]; i++)
     {
	for (j = 0; j < dims[1]; j++)
	  {
	     for (k = 0; k < dims[2]; k++)
	       b += a[i,j,k];
	  }
     }
   return b;
}

A = [1:3*4*5];
reshape (A, [3,4,5]);

define test_sum (a, n)
{
   variable s1, s2;

   if (n == -1)
     s1 = sum(A);
   else
     s1 = sum(A,n);

   s2 = compute_sum (A, n);

   if (neqs (s1, s2))
     {
	failed ("sum(A,%d): %S != %S: %g != %g", n, s1, s2, s1[0,0], s2[0,0]);
     }
}

test_sum (A,-1);
test_sum (A,2);
test_sum (A,1);
test_sum (A,0);

#ifexists Complex_Type
A = [1+2i, 2+3i, 3+4i];
if (sum(A) != A[0] + A[1] + A[2])
  failed ("sum(Complex)");
#endif

#endif				       %  Double_Type

define find_min (a)
{
   %a = a[where(not isnan(a))];
   a = a[wherenot (isnan(a))];
   variable m = a[0];
   _for (1, length(a)-1, 1)
     {
	variable i = ();
	if (a[i] < m)
	  m = a[i];
     }
   return m;
}

define find_max (a)
{
   a = a[where (not isnan(a))];
   variable m = a[0];
   _for (1, length(a)-1, 1)
     {
	variable i = ();
	if (a[i] > m)
	  m = a[i];
     }
   return m;
}

define test_eqs (what, a, b)
{
   if (_typeof(a) != _typeof(b))
     failed ("%s: %S != %S", what, a, b);

   if (neqs (a, b))
     failed ("%s: %S != %S", what, a, b);
}

private define shuffle (a)
{
   variable i, n = length (a);
   variable list = {};
   _for i (0, n-1, 1)
     list_append (list, a[i]);

   variable b = @a;
   i = 0;
   do
     {
	variable j = int (n*urand ());
	b[i] = sign (0.5-urand()) * list_pop (list, j);
	n--; i++;
     }
   while (n);
   return b;
}

private define test_min_maxabs (a)
{
   a = shuffle (a);
   test_eqs ("minabs", minabs(a), min(abs(a)));
   test_eqs ("maxabs", maxabs(a), max(abs(a)));
}

A = [1:10];
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);
#ifexists Double_Type
A *= 1.0f;
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);
A *= 1.0;
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);
#endif
A = [1h:10h];
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);
A = ['0':'9'];
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);

A = [1.0:10]; A[0] = _NaN;
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);

A = [1.0:10]; A[-1] = _NaN;
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);

A = [1.0:10]; A[3] = _NaN;
test_eqs ("min", min(A), find_min(A));
test_eqs ("max", max(A), find_max(A));
test_min_maxabs(A);

private define test_eqsmin_max_all_types (A)
{
   foreach (Util_Arith_Types)
     {
	variable t = ();
	variable b = typecast (A, t);
	test_eqs ("min", min(b), find_min(b));
	test_eqs ("max", max(b), find_max(b));
	test_min_maxabs(b);
     }
}
test_eqsmin_max_all_types ([10:20]);

if ((_min(2, 1) != 1) or (_min(1,2) != 1))
  failed ("_min");
if ((_max(2, 1) != 2) or (_max(1,2) != 2))
  failed ("_max");

A=Int_Type[10,10];
A[*,*] = [0:99];
if (length (A[[0:99:11]]) != 10)
  failed ("A[[0:99:11]");

if ((_min(_NaN, 1) != 1) or (_min(1,_NaN) != 1))
  failed ("_min with NaN");
if ((_max(_NaN, 1) != 1) or (_max(1,_NaN) != 1))
  failed ("_max with NaN");

#ifexists cumsum
private define do_cumsum (a)
{
   variable b = 1.0 * a;
   variable i, s;

   s = 0;
   _for (0, length(a)-1, 1)
     {
	i = ();
	s += a[i];
	b[i] = s;
     }
   return b;
}

private define test_cumsum (a, k, result_type)
{
   variable b = 1.0 * a;
   variable bb;

   variable dims, ndims;
   variable i, j;
   (dims, ndims, ) = array_info (a);

   if (k != -1)
     bb = cumsum (a, k);
   else
     bb = cumsum (a);

   if (_typeof (bb) != result_type)
     {
	failed ("cumsum(%S) has wrong return type (%S)", a, b);
     }
#ifexists Complex_Type
   if ((_typeof (a) != Complex_Type) and (_typeof (a) != Float_Type))
#endif
     a = typecast (a, Double_Type);

   if (k == -1)
     {
	b = do_cumsum (_reshape (a, [length(a)]));
     }
   else switch (ndims)
     {
      case 1:
	b = cumsum (a);
     }
     {
      case 2:
	if (k == 0)
	  {
	     %a_j = cumsum_i a_ij
	     _for (0, dims[1]-1, 1)
	       {
		  j = ();
		  b[*, j] = do_cumsum (a[*, j]);
	       }
	  }
	else
	  {
	     _for (0, dims[1]-1, 1)
	       {
		  i = ();
		  b[i, *] = do_cumsum (a[i, *]);
	       }
	  }
     }
     {
      case 3:
	if (k == 0)
	  {
	     %a_j = cumsum_i a_ij
	     _for (0, dims[1]-1, 1)
	       {
		  i = ();
		  _for (0, dims[2]-1, 1)
		    {
		       j = ();
		       b[*, i, j] = do_cumsum (a[*, i, j]);
		    }
	       }
	  }
	else if (k == 1)
	  {
	     _for (0, dims[0]-1, 1)
	       {
		  i = ();
		  _for (0, dims[2]-1, 1)
		    {
		       j = ();
		       b[i, *, j] = do_cumsum (a[i, *, j]);
		    }
	       }
	  }
	else
	  {
	     _for (0, dims[0]-1, 1)
	       {
		  i = ();
		  _for (0, dims[1]-1, 1)
		    {
		       j = ();
		       b[i, j, *] = do_cumsum (a[i, j, *]);
		    }
	       }
	  }
     }

   if (neqs (b, bb))
     {
	failed ("cumsum (%S, %d), expected %S, got %S", a, k, b, bb);
     }
}

A = Int_Type[10]; A[*] = 1;
test_cumsum (A, -1, Double_Type);
test_cumsum (A, 0, Double_Type);
A = [1:3*4*5];
reshape (A, [3,4,5]);
test_cumsum (A, -1, Double_Type);
test_cumsum (A, 0, Double_Type);
test_cumsum (A, 1, Double_Type);
test_cumsum (A, 2, Double_Type);

A = Char_Type[10]; A[*] = 1;
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
A = [1:3*4*5]; A = typecast (A, Char_Type);
reshape (A, [3,4,5]);
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
test_cumsum (A, 1, Float_Type);
test_cumsum (A, 2, Float_Type);

A = UChar_Type[10]; A[*] = 1;
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
A = [1:3*4*5]; A = typecast (A, UChar_Type);
reshape (A, [3,4,5]);
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
test_cumsum (A, 1, Float_Type);
test_cumsum (A, 2, Float_Type);

A = Short_Type[10]; A[*] = 1;
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
A = [1:3*4*5]; A = typecast (A, Short_Type);
reshape (A, [3,4,5]);
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
test_cumsum (A, 1, Float_Type);
test_cumsum (A, 2, Float_Type);

A = UShort_Type[10]; A[*] = 1;
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
A = [1:3*4*5]; A = typecast (A, UShort_Type);
reshape (A, [3,4,5]);
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
test_cumsum (A, 1, Float_Type);
test_cumsum (A, 2, Float_Type);

A = Float_Type[10]; A[*] = 1;
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
A = [1:3*4*5]*1.0f;
reshape (A, [3,4,5]);
test_cumsum (A, -1, Float_Type);
test_cumsum (A, 0, Float_Type);
test_cumsum (A, 1, Float_Type);
test_cumsum (A, 2, Float_Type);

#ifexists Complex_Type
A = Complex_Type[10]; A[*] = 1;
test_cumsum (A, -1, Complex_Type);
test_cumsum (A, 0, Complex_Type);
A = [1:3*4*5] + 2i*[1:3*4*5];
reshape (A, [3,4,5]);
test_cumsum (A, -1, Complex_Type);
test_cumsum (A, 0, Complex_Type);
test_cumsum (A, 1, Complex_Type);
test_cumsum (A, 2, Complex_Type);
#endif

#endif

private variable I;
A=[1:100];
I = Int_Type[3,3];
if (neqs (array_dims (A[I]), array_dims(I)))
  failed ("A[I] 3x3 dims");
I = Int_Type[0,0];
if (neqs (array_dims (A[I]), array_dims(I)))
  failed ("A[I] 0x0 dims");

A =_reshape ([1:100], [5,20]);
I = Int_Type[3,3];
if (neqs (array_dims (A[I]), array_dims(I)))
  failed ("A[I] 3x3 dims");
I = Int_Type[0,0];
if (neqs (array_dims (A[I]), array_dims(I)))
  failed ("A[I] 0x0 dims");
if (neqs (A[0,*], [1:20]))
  failed ("A[0,*]");
if (neqs (A[-1,*], [81:100]))
  failed ("A[-1,*]");
I = _reshape ([20,30,40,50], [2,2]);
if (neqs (A[I], _reshape ([21,31,41,51],[2,2])))
  failed ("A[I] for [20,30;40,50]");
#iffalse
if (length (A[[-1:0]]) != 0)
  failed ("A[[-1:0]]");
#else
if (length (A[[99:0]]) != 0)
  failed ("A[[99:0]]");
#endif

% Now test the examples from the documentation

define test_example ()
{
   variable a = Integer_Type [10, 10];
   variable j;
   for (j = 0; j < 10; j++) a[j, j] = 5;

   variable b = Integer_Type [10, 10];
   j = [[0:99:11]];
   b[j] = 5;

   if (0 == _eqs (a, b))
     failed ("Example 1");
}
test_example ();

#ifexists array_swap
private define test_array_swap (a, i, j)
{
   variable b = @a;
   array_swap (a, i, j);
   (b[i], b[j]) = (b[j], b[i]);
   if (0 == _eqs (a, b))
     failed ("array_swap");
}
test_array_swap ([1:5], 0, 0);
test_array_swap ([1:5], 0, 1);
test_array_swap ([1:5], 0, -1);
test_array_swap ([1:5], -2, -1);
test_array_swap ([1:5], 3, 4);
test_array_swap (["ab", "cd", "ef", "gh", "ij"], 3, 4);
#endif

#ifexists array_reverse
private define test_array_reverse (a, i, j)
{
   variable b = @a;
   if (i == NULL)
     {
	array_reverse (a);
	i = 0;
	j = length (a)-1;
     }
   else
     array_reverse (a, i, j);

   b[[i:j]] = b[[j:i:-1]];
   if (0 == _eqs (a, b))
     failed ("array_reverse");
}
test_array_reverse ([1:5], 0, 0);
test_array_reverse ([1], 0, 0);
test_array_reverse ([1:5], 2, 3);
test_array_reverse ([1:5], 4, 4);
test_array_reverse ([1:5], 3, 4);
test_array_reverse ([1:5], 0, 1);
test_array_reverse ([1:5], NULL, 1);
test_array_reverse (["ab", "cd", "ef", "gh", "ij"], 3, 4);
test_array_reverse (["ab", "cd", "ef", "gh", "ij"], NULL, 4);

private define test_2darray_reverse (a, i, j, dim)
{
   variable b = @a;
   try
     {
	if (i == NULL)
	  {
	     array_reverse (a, dim);
	     i = 0;
	     variable dims;
	     (dims,,) = array_info (a);
	     j = dims[dim]-1;
	  }
	else
	  array_reverse (a, i, j, dim);
     }
   catch NotImplementedError: return;

   if (dim == 0)
     b[*, [i:j]] = b[*, [j:i:-1]];
   else
     b[[i:j], *] = b[[j:i:-1], *];
   if (0 == _eqs (a, b))
     failed ("array_reverse 2d");
}

test_2darray_reverse (_reshape ([1:3*4], [3,4]), NULL, NULL, 0);
test_2darray_reverse (_reshape ([1:3*4], [3,4]), NULL, NULL, 1);
test_2darray_reverse (_reshape ([1:3*4], [3,4]), 1,2, 0);
test_2darray_reverse (_reshape ([1:3*4], [3,4]), 1,3, 1);
#endif

#ifexists __aget
private define test_aget ()
{
   variable a, indices;
   indices = __pop_args (_NARGS-1);
   a = ();

   if (__aget (a, __push_args(indices)) != a[__push_args(indices)])
     failed ("aget");

   try
     {
	__aget (a);
     }
   catch IndexError;
   try
     {
	__aget (a, __push_args(indices), 1);
     }
   catch IndexError;
}

private variable A = [1:3*7*11];
test_aget (A, 3*4*5);
test_aget (A, -1);
test_aget (A, -20);
test_aget (A, -20);
reshape (A, [3,7,11]);
test_aget (A, -1,-1,-1);
test_aget (A, 0,0,0);
test_aget (A, 1,3,5);

private define test_aput ()
{
   variable a, x, indices;

   % test_aput (val, a, indices);
   indices = __pop_args (_NARGS-2);
   (x,a) = ();

   __aput (x, a, __push_args(indices));
   if (not _eqs (a[__push_args(indices)], x))
     failed ("aget");

   try
     {
	__aput (x, a);
     }
   catch IndexError;
   try
     {
	__aput (x, a, __push_args(indices), 1);
     }
   catch IndexError;
}

private variable A = [1:3*7*11];
test_aput (1023, A, 3*4*5);
test_aput (1024, A, -1);
test_aput (1024, A, -20);
test_aput (1024, A, -20);
reshape (A, [3,7,11]);
test_aput (1024, A, -1,-1,-1);
test_aput (1035, A, 0,0,0);

A = ["foo", "bar", "bob"];
test_aput ("goober", A, -1);
test_aput ("goober", A, 0);
A = Array_Type [4];
test_aput ([1:4], A, 2);
#endif

A = Int_Type[2,3,4];
A[*] = [1:24];
if (neqs (A[0,0,*], [1,2,3,4]))
  failed ("A[*]=[1:24];A[0,0,*]");
if (neqs (A, _reshape([1:24], [2,3,4])))
  failed ("A[*]=[1:24]");
if (neqs(A[0,0,[-2:3]],[3,4,1,2,3,4]))
  failed ("A[0,0,[-2:3]]");
if (neqs (A,A[*,*,*]))
  failed ("A[*,*,*]");

A = [1:10];
A[[0:9]] += 1;
if (not _eqs (A, [2:11]))
  failed ("A[[0:9]] += 1");
A[[0:9]] += A[[0:9]];
if (not (_eqs (A, [2:11]*2)))
  failed ("A[[0:9]] += A[[0:9]]");

A = [1:10];
A[*] += 1;
if (not _eqs (A, [2:11]))
  failed ("A[*] += 1");
A[*] += A[*];
if (not (_eqs (A, [2:11]*2)))
  failed ("A[*] += A[*]");

private define index_random ()
{
   variable a = [1:60];
   variable n = Int_Type[83]; n[*] = 70;
   loop (5)
     {
	try
	  {
	     i = array_map (Double_Type, &random, n);
	     i = int (i*2-70);
	     () = a[i];
	  }
	catch IndexError;
     }
}
index_random ();

% Finally make sure 0 a 0 increment is not allowed
try
{
   () = [1:10:0];
   failed ("range array with 0 increment");

}
catch InvalidParmError;

private define test_any_1 (astr, ans)
{
   variable ans1 = any(eval(astr));
   if (ans != ans1)
     failed ("any(%S) != %S", astr, ans);
   if (typeof (ans1) != Char_Type)
     failed ("any(%S) returned %S", astr, typeof(ans1));
}
private define test_all_1 (astr, ans)
{
   variable ans1 = all(eval(astr));
   if (ans != ans1)
     failed ("all(%S) != %S", astr, ans);
   if (typeof (ans1) != Char_Type)
     failed ("all(%S) returned %S", astr, typeof(ans1));
}

private define test_any_or_all (fun, astr, ans)
{
   foreach (Util_Arith_Types)
     {
	variable t = ();
	(@fun) ("typecast ($astr, $t);"$, ans);
     }
}

private define test_any (astr, ans)
{
   test_any_or_all (&test_any_1, astr, ans);
}

private define test_all (astr, ans)
{
   test_any_or_all (&test_all_1, astr, ans);
}

test_any ("[0,0,0,0]", 0);
test_any ("[0,0,0,1]", 1);
test_any ("[0,0,1,0]", 1);
test_any ("[0,1,0,0]", 1);
test_any ("[1,0,0,0]", 1);
test_any ("[0]", 0);
test_any ("[1]", 1);
test_any ("Int_Type[0]", 0);

test_all ("[0,0,0,0]", 0);
test_all ("[0,0,0,1]", 0);
test_all ("[0,0,1,0]", 0);
test_all ("[0,1,0,0]", 0);
test_all ("[1,0,0,0]", 0);
test_all ("[0]", 0);
test_all ("[1]", 1);
test_all ("[1,1,1,1]", 1);
test_all ("[1,1,1,0]", 0);
test_all ("[1,1,0,1]", 0);
test_all ("[1,0,1,1]", 0);
test_all ("[0,1,1,1]", 0);
test_all ("Int_Type[0]", 0);

test_all_1 ("[1.0,_NaN]", 1);
test_any_1 ("[1.0,_NaN]", 1);
test_any_1 ("[_NaN]", 0);
test_all_1 ("[_NaN]", 1);

define test_where_first_last (a)
{
   variable i = where (a);
   variable i0 = wherefirst (a);
   variable i1 = wherelast (a);

   if (length (i) == 0)
     {
	if ((i0 != NULL) or (i1 != NULL))
	  failed ("Expected wherefirst/wherelast to return NULL");
	return;
     }
   if (i0 != i[0])
     failed ("wherefirst");
   if (i1 != i[-1])
     failed ("wherelast");

   i0 = wherefirst (a, 0);
   i1 = wherelast (a, -1);

   if (i0 != i[0])
     failed ("wherefirst 0");
   if (i1 != i[-1])
     failed ("wherelast -1");

   i0 = wherefirst (a, i0);
   i1 = wherelast (a, i1);
   if (i0 != i[0])
     failed ("wherefirst i0");
   if (i1 != i[-1])
     failed ("wherelast i1");
}

test_where_first_last ([1:10] == 1);
test_where_first_last ([1:10] == -1);
test_where_first_last ([1:10] == 2);
test_where_first_last ([1:10] == 10);
test_where_first_last ([1:10] == 9);
test_where_first_last ([1:10] > 1);
test_where_first_last ([1:10] < 10);
test_where_first_last ([1:10] == 5);
test_where_first_last ([1:10] mod 2);
test_where_first_last ([1:10] mod 3);

test_where_first_last ([0:-1] == 1);

if (length ([1,2,]) != 2)
  failed ("2-element array with trailing comma has wrong length");
if (length ([1,]) != 1)
  failed ("1-element array with trailing comma has wrong length");

try
{
   eval("() = [,];");
   failed ("Illegal commas in array not caught");
   eval("() = [1,,];");
   failed ("Illegal commas in array not caught");
   eval("() = [1,2,,];");
   failed ("Illegal commas in array not caught");
}
catch SyntaxError;

% inline array of different types
private define test_array_types (a, b)
{
   variable t = typeof (a+b);

   if ((t != _typeof ([a,b]))
       or (t != _typeof ([[a],[b]]))
       or (t != _typeof ([[a],b]))
       or (t != _typeof ([a,[b]]))
       or (t != _typeof ([[b],a]))
       or (t != _typeof ([b,a]))
       or (t != _typeof ([[b],[a]])))
     {
	failed ("array of %S and %S not of expected type %S", typeof(a), typeof(b));
     }
}

test_array_types (1h, 1L);
test_array_types (1h, 1f);
test_array_types (1h, 1.0);
#ifexists Complex_Type
test_array_types (1h, 1j);
#endif
test_array_types ("a", "a\0");

% Test presence of NULLs in inline arrays
private define test_nulls_in_array (arr, is_good)
{
   try
     {
	eval ("()=" + arr);
	if (is_good)
	  return;
	failed ("%s should have generated an error", arr);
     }
   catch TypeMismatchError:
     {
	if (is_good)
	  failed ("typemismatch evaluating %s", arr);
     }
}

test_nulls_in_array ("[NULL, &sin]", 1);
test_nulls_in_array ("[&sin, NULL]", 1);
test_nulls_in_array ("[&sin, NULL,NULL,NULL,NULL]", 1);
test_nulls_in_array ("[NULL,NULL,&sin,NULL,NULL]", 1);
test_nulls_in_array ("[NULL,NULL,&sin,[&sin,NULL]]", 1);
test_nulls_in_array ("[1,2,NULL]", 0);
test_nulls_in_array ("[1,NULL]", 0);
test_nulls_in_array ("[1,NULL,]", 0);
test_nulls_in_array ("[1,NULL,2]", 0);

define test_bool_ops ()
{
   variable a = typecast ([1,2,3,4,0], Char_Type);
   variable b = typecast ([1,2,0,5,0], Char_Type);
   variable i = where (a == b);
   if (0 == eqs (i, [0,1,4]))
     failed ("test_bool_ops: a==b");
   i = where (a != b);
   if (0 == eqs (i, [2,3]))
     failed ("test_bool_ops: a!=b");
   i = where (a or b);
   if (0 == eqs (i, [0,1,2,3]))
     failed ("test_bool_ops: a or b");
   i = where (a and b);
   if (0 == eqs (i, [0,1,3]))
     failed ("test_bool_ops: a and b");
}
test_bool_ops ();

private define test_where_2_args (a)
{
   variable i0, j0, i1, j1;
   i0 = where (a);
   j0 = wherenot(a);
   i1 = where (a, &j1);

   if ((not eqs (i0, i1)) or (not eqs (j0, j1)))
     {
	failed ("where_2_args");
     }
}

test_where_2_args (([1:10] mod 2)==0);
test_where_2_args (([1:10] mod 2)==1);
test_where_2_args (([1:10] mod 3)==0);
test_where_2_args (([1:10] mod 3)==1);
test_where_2_args (([1:10] mod 3)==2);
test_where_2_args (([1:-1] mod 2)==2);

private define test_arrayn (a, b, n)
{
   variable a0;

   if (n == 1)
     a0 = a;
   else
     a0 = a + ([0:n-1])*((b-a)/double(n-1));
   variable a1 = [a:b:#n];

   if ((typeof (a) == Float_Type) && (_typeof(a1) != Float_Type))
     {
	failed ("Expecting [%g:%g:#%g] to be Float_Type", a,b,n);
     }

   if (n <= 0)
     {
	if (length (a1) != 0)
	  failed ("expecting [$a:$b:$n] to have 0 length"$);
	return;
     }

   variable tol = 1e15;

   tol = 1e-15;
   if (max (_diff(a1,a0)>tol*abs(a)))
     failed ("[$a:$b:$n] max_diff=%g"$, max(_diff(a1,a0)));
}

test_arrayn (1,10, 1);
test_arrayn (1,10, 10);
test_arrayn (1,20, 10);
test_arrayn (-5, 5, 10);
test_arrayn (33.1, 45.0, 2048);
test_arrayn (33.1, 45.0, 0);
test_arrayn (33.1, 45.0, -5);
test_arrayn (0f,255f,256);

private define test_array_refs ()
{
   variable a = String_Type[10, 10];
   variable r = &a[5,5];

   @r = "foo";
   if (a[5,5] != "foo")
     failed ("&a[5,5]");

   r = &a[[2,3],[4,5,6]];
   @r = ["1x", "2x", "3x", "4x", "5x","6x"];
   if ((a[2,4] != "1x") or (a[3,6] != "6x"))
     failed ("&a[[2,3],[4,5,6]]");

   ifnot (_eqs (@r, _reshape (["1x", "2x", "3x", "4x", "5x","6x"], [2,3])))
     {
	failed ("@r = %S did not produce expected result", @r);
     }
}
test_array_refs ();

define test_string_array()
{
   variable i, n = 20, m = 10;
   variable A = String_Type[n];
   A[[*]] = "foo";
   ifnot (all (A == "foo"))
     failed ("A[*]=\"foo\"");
   A[[0:n-1]] = "bar";
   ifnot (all (A == "bar"))
     failed ("A[[0:n-1]]=\"foo\"");

   A[[0::2]] = "ebar";
   i = where (A=="ebar");
   if (length (i) != n/2)
     failed ("A[[0::2]]=ebar");
   if (any(i mod 2))
     failed ("A[[0::2]]=ebar (mod)");

   variable B = String_Type[n,m];
   B[[0::2],*] = "foo";
   ifnot (all(_isnull (B[[1::2],*])))
     failed ("B[[0::2],*]=foo");
   B[*,1] = A;
   ifnot (_eqs(B[*,1], A))
     failed ("B[*,1]=A");
   A = transpose(B[*,[:]]);
   variable C = @A;
   C[*,*] = transpose(B);
   ifnot (_eqs(C[3,[1,3,5,6]], A[3,[1,3,5,6]]))
     failed ("transpose(B[*,[:]])");
   ifnot (_eqs(C[[1:3],[5:7]], A[[1,2,3],[5,6,7]]))
     failed ("transpose(B[*,[:]], test2");
}
test_string_array ();

define test_range_arith (a, x)
{
   ifnot (_eqs (a/1 + x, a+x))
     failed ("range addition");

   ifnot (_eqs (a/1 - x, a-x))
     failed ("range subtraction");

   ifnot (_eqs ((a/1) * x, a*x))
     failed ("range multiplication");

   ifnot (_eqs (x + a/1, x+a))
     failed ("x range addition");

   ifnot (_eqs (x-a/1, x-a))
     failed ("x range subtraction");

   ifnot (_eqs (x*(a/1), x*a))
     failed ("x range multiplication");
}

test_range_arith ([1:10], 2);
test_range_arith ([1:10:3], -1);
test_range_arith ([10:1:-2], 2);
test_range_arith ([10:1:-2], 1);
test_range_arith ([10:1:-2], -1);
test_range_arith ([10:1:-2], -10);

define test_dup (a)
{
   variable b = @a;
   if (__is_same (a, b))
     failed ("b=@a failed __is_same");
   ifnot (_eqs (a,b))
     failed ("b=@a failed _eqs");
}
test_dup ([1:10]);
test_dup ([1:-3]);
test_dup ([1:4]);
test_dup ([1,2,3,4]);
test_dup (["foo", "bar", "baz"]);

private define test_sumsq (a)
{
   variable s, t;

   s = sumsq (a);
#ifexists Complex_Type
   if (_typeof (a) == Complex_Type)
     t = sumsq (Real(a)) + sumsq(Imag(a));
   else
#endif
     t = sum (a*a);

   if (s != t)
     {
	failed ("sumsq: %S != %S, diff=%S", s, t, s-t);
     }
}
test_sumsq ([1:10]);
test_sumsq (typecast ([1:10], Char_Type));
test_sumsq (typecast ([1:10], UChar_Type));
test_sumsq (typecast ([1:10], Long_Type));
test_sumsq (typecast ([1:10], ULong_Type));
test_sumsq (typecast ([1:10], Short_Type));
test_sumsq (typecast ([1:10], UShort_Type));
#ifexists Double_Type
test_sumsq (typecast ([1:10], Float_Type));
test_sumsq (typecast ([1:10], Double_Type));
#endif
#ifexists Complex_Type
test_sumsq ([1:10] + [2:11]*1i);
#endif

private define test_linear_combination ()
{
   foreach ({1, 1.0})
     {
	variable one = ();

	variable a = [1, 2, 3, 4] * one;
	variable b = [1, 2, 3, 4];
	variable ans, ans1;

	ans = sum (a*b);
	ans1 = 1*a[0] + 2*a[1] + 3*a[2] + 4*a[3];
	if (ans != ans1)
	  failed ("%S*%S linear combination1 not equal to sum", _typeof(a), _typeof(b));

	ans1 = a[0]*1 + a[1]*2 + a[2]*3 + a[3]*4;
	if (ans != ans1)
	  failed ("%S*%S linear combination2 not equal to sum", _typeof(a), _typeof(b));
     }

}
test_linear_combination ();

private define test_range_multiplier ()
{
   variable x0 = 1.7, x1 = 2.05, dx = 0.02;
   variable a = [x0:x1:dx];
   if (a[0] != x0)
     failed ("range multiplier: first element is incorrect (%S vs %S", a[0], x0);
   x0 = -1.7;
   a = [x0:x1:dx];
   if (a[0] != x0)
     failed ("range multiplier: first element is incorrect (%S vs %S", a[0], x0);
}
test_range_multiplier ();

private define test_wherefirstlast_minmax (a)
{
   foreach (Util_Arith_Types)
     {
	variable type = ();
	variable b = typecast (a, type);

	variable i;
	i = wherefirst (b == min(b));
	if (i != wherefirstmin (b))
	  failed ("wherefirstmin on %S", type, b);

	i = wherefirst (b == max(b));
	if (i != wherefirstmax (b))
	  failed ("wherefirstmax on %S", type, b);

	i = wherelast (b == min(b));
	if (i != wherelastmin (b))
	  failed ("wherelastmin on %S", type, b);

	i = wherelast (b == max(b));
	if (i != wherelastmax (b))
	  failed ("wherelastmax on %S", type, b);
     }
}

test_wherefirstlast_minmax (1);
test_wherefirstlast_minmax ([1]);
test_wherefirstlast_minmax ([-1,1]);
test_wherefirstlast_minmax ([-1,1,-1]);
test_wherefirstlast_minmax ([-1,1,-1,1]);
test_wherefirstlast_minmax ([-1,1,-1,1,0]);
test_wherefirstlast_minmax ([-1,1,-1,1,0,1,2,3]);
test_wherefirstlast_minmax ([-1,1,-1,1,0,1,2,3,0]);

private define test_prod (a)
{
   variable p = prod (a);
   variable p1 = 1.0;
   foreach (a)
     {
	variable aa = ();
	p1 *= aa;
     }
   if (p1 == p)
     return;
#ifexists Complex_Type
   if (_typeof (a) == Complex_Type)
     {
	if (feqs (Real(p), Real(p1)) && feqs (Imag(p), Imag(p1)))
	  return;
     }
   else
#endif
     {
	if (feqs (p, p1))
	  return;
     }

   failed ("prod(%S) produced %S, expected %S", a, p, p1);
}
test_prod ([1]);
test_prod ([1:5]);
test_prod ([1.0]);
test_prod ([1.0f]);
test_prod ([1:5]*1.0);
test_prod ([1:5]*1.0f);
test_prod ([1h, 2h]);
#ifexists LLong_Type
test_prod ([1LL]);
test_prod ([1:5]*1LL);
#ifexists Complex_Type
test_prod ([1+0i]);
test_prod ([1:5] + 1i*[2:6]);
#endif

private define test_wherefirst_op ()
{
   variable types = Util_Arith_Types;

   variable ops = {"_op_eqs", "_op_neqs", "_op_gt", "_op_ge", "_op_lt", "_op_le"};
   loop (5)
     {
	foreach (ops)
	  {
	     variable op = ();
	     variable suffix = op[[3:5]];
	     variable wherefirst_func = __get_reference ("wherefirst" + suffix);
	     variable wherelast_func = __get_reference ("wherelast" + suffix);
	     op = __get_reference (op);

	     variable a = 128*urand(1000);
	     variable b = 128*urand();
	     variable istart = int (-10 + 10*urand ());
	     variable aa, bb, atype, btype, i, j;

	     foreach atype (types)
	       {
		  aa = typecast (a, atype);
		  foreach btype (types)
		    {
		       bb = typecast (b, btype);
		       i = (@wherefirst_func)(aa, bb);
		       j = wherefirst ((@op)(aa, bb));
		       if (i != j)
			 {
			    failed ("%S(%S,%S %S)==>a[%S]=%S, expected a[%S]=%S",
				    wherefirst_func, aa, btype, bb,
				    i, (i==NULL?"NULL":aa[i]),
				    j, (j==NULL?"NULL":aa[j]));
			 }

		       i = (@wherelast_func)(aa, bb);
		       j = wherelast ((@op)(aa, bb));
		       if (i != j)
			 {
			    failed ("%S(%S,%S %S)==>a[%S]=%S, expected a[%S]=%S",
				    wherelast_func, aa, btype, bb,
				    i, (i==NULL?"NULL":aa[i]),
				    j, (j==NULL?"NULL":aa[j]));
			 }

		       i = (@wherefirst_func)(aa, bb, istart);
		       j = wherefirst ((@op)(aa, bb), istart);
		       if (i != j)
			 {
			    failed ("%S(%S,%S %S)==>a[%S]=%S, expected a[%S]=%S",
				    wherefirst_func, aa, btype, bb, istart,
				    i, (i==NULL?"NULL":aa[i]),
				    j, (j==NULL?"NULL":aa[j]));
			 }

		       i = (@wherelast_func)(aa, bb, istart);
		       j = wherelast ((@op)(aa, bb), istart);
		       if (i != j)
			 {
			    failed ("%S(%S,%S %S,%S)==>a[%S]=%S, expected a[%S]=%S",
				    wherelast_func, aa, btype, bb, istart,
				    i, (i==NULL?"NULL":aa[i]),
				    j, (j==NULL?"NULL":aa[j]));
			 }
		    }
	       }
	  }
     }
}

test_wherefirst_op ();

private define test_wherediff ()
{
   variable a =  [1, 1, 3, 0, 0, 4, 7, 7];
   variable i, j;

   i = wherediff (a, &j);
   ifnot (_eqs (i, [0, 2, 3, 5, 6]) && _eqs(j, [1, 4, 7]))
     failed ("wherediff test1");

   i = wherediff (Int_Type[0], &j);
   if (length(i) || length(j))
     failed ("wherediff test2");

   a = ["foo"];
   i = wherediff (a, &j);
   ifnot (_eqs (i, [0]) && _eqs(j, Int_Type[0]))
     failed ("wherediff test3");
   a = ["foo"];

   a = String_Type[3];
   i = wherediff (a, &j);
   ifnot (_eqs (i, [0]) && _eqs(j, [1,2]))
     failed ("wherediff test4");
}
test_wherediff ();

private define test_init_char_array (s)
{
   variable t;
   foreach t ([Char_Type, UChar_Type])
     {
	variable a = t[strbytelen (s)];
	init_char_array (a, s);

	variable i;
	_for i (0, length(a)-1, 1)
	  {
	     if (a[i] != typecast (s[i], t))
	       failed ("init_char_array: type=%S", t);
	  }
     }
}

test_init_char_array ("HelloWorld");
test_init_char_array ("\xAB\xCD\xEF");

private define check_indices (a, idx, ans)
{
   variable b;
   try
     {
	b = a[idx];
	if (ans == NULL) failed ("get: Bad index not detected");
     }
   catch IndexError:
     {
	if (ans != NULL) failed ("get: Bad index exception erroneously caught");
     }
   if ((ans != NULL)
       && (not _eqs (ans, b)))
     {
	failed ("check_indices: Unexpected result: %S != %S", b, ans);
     }

   b = @a;
   try
     {
	b[idx] = a[idx];
	if (ans == NULL) failed ("put: Bad index not detected");
     }
   catch IndexError:
     {
	if (ans != NULL) failed ("put: Bad index exception erroneously caught");
     }
}
check_indices ([1,2,3], [0:2], [1,2,3]);
check_indices ([1,2,3], [:2], [1,2,3]);
check_indices ([1,2,3], [:3], NULL);
check_indices ([1,2,3], [:-2], [1,2]);
check_indices ([1,2,3], [:-3], [1]);
check_indices ([1,2,3], [:-4], Int_Type[0]);
check_indices ([1,2,3], [:-5], Int_Type[0]);
check_indices ([1,2,3], [-1:], [3]);
check_indices ([1,2,3], [-3:], [1,2,3]);
check_indices ([1,2,3], [-4:], NULL);
check_indices ([1,2,3], [:3:-1], Int_Type[0]);
check_indices ([1,2,3], [::-1], [3,2,1]);

check_indices ([1,2,3], [-1::-1], [3,2,1]);
check_indices ([1,2,3], [0:3], NULL);
check_indices ([1,2,3], [0,3], NULL);
check_indices ([1,2,3], [-4,-2,-1], NULL);
check_indices ([1,2,3], [2:-3], Int_Type[0]);
check_indices (["foo", "bar", "baz"], [0:3], NULL);
check_indices (["foo", "bar", "baz"], [0,3], NULL);
check_indices (["foo", "bar", "baz"], [-4,-2,-1], NULL);
check_indices (["foo", "bar", "baz"], [2:-3], String_Type[0]);

print ("Ok\n");
exit (0);

