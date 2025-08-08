! Copyright (c) Joby Aviation 2022
! Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
!
! Copyright (c) Thulio Ferraz Assis 2024
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

program tabulate
    use user_functions
    use omp_lib

    implicit none
    real    :: x, xbegin, xend
    integer :: i, steps
    integer :: num_threads

    num_threads = omp_get_max_threads()
    write(*,*) 'Running with ', num_threads, ' OpenMP threads'

    write(*,*) 'Please enter the range (begin, end) and the number of steps:'
    read(*,*)  xbegin, xend, steps

    write(*,*) 'X        F(X)      Thread'
    
    !$omp parallel do private(x) schedule(static)
    do i = 0, steps
        x = xbegin + i * (xend - xbegin) / steps
        !$omp critical
        write(*,'(2f10.4, i6)') x, f(x), omp_get_thread_num()
        !$omp end critical
    end do
    !$omp end parallel do
end program tabulate
