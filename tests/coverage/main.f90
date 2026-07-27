! Copyright (c) Thulio Ferraz Assis 2026
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

program fortran_links_instrumented_c
  use, intrinsic :: iso_c_binding, only: c_int
  implicit none

  interface
    function add_one(value) bind(C, name='add_one')
      import :: c_int
      integer(c_int), value :: value
      integer(c_int) :: add_one
    end function add_one
  end interface

  if (add_one(1_c_int) /= 2_c_int) then
    error stop 'add_one(1) did not return 2'
  end if

  write(*,'(a)') adjustl('OK')
end program fortran_links_instrumented_c
