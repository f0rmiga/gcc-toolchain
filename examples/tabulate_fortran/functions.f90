module user_functions
    implicit none
contains

real function f( x )
    real, intent(in) :: x
    f = x - x**2 + sin(x)
end function f

end module user_functions
