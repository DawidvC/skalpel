type x = int

signature SIG1 =
sig
    type t1
    sharing type t1 = x
end;
