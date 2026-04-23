module mod_crivo
    implicit none
contains
    subroutine executar_atkin(limite)
        integer(kind=8), intent(in) :: limite
        logical(kind=1), allocatable :: eh_primo(:)
        integer(kind=8) :: x, y, n, s, x2, y2
        real(8) :: t1, t2

        print *, "--- Iniciando Crivo de Atkin ---"
        print *, "Limite:", limite
        
        allocate(eh_primo(limite))
        eh_primo = .false.

        call cpu_time(t1)

        !$OMP PARALLEL DO PRIVATE(x, y, n, x2, y2) SHARED(eh_primo) SCHEDULE(GUIDED)
        do x = 1, int(sqrt(real(limite, 8)))
            x2 = x*x
            do y = 1, int(sqrt(real(limite, 8)))
                y2 = y*y
                
                n = 4*x2 + y2
                if (n <= limite .and. (mod(n, 12) == 1 .or. mod(n, 12) == 5)) then
                    !$OMP ATOMIC
                    eh_primo(n) = eh_primo(n) .neqv. .true.
                end if

                n = 3*x2 + y2
                if (n <= limite .and. mod(n, 12) == 7) then
                    !$OMP ATOMIC
                    eh_primo(n) = eh_primo(n) .neqv. .true.
                end if

                n = 3*x2 - y2
                if (x > y .and. n <= limite .and. mod(n, 12) == 11) then
                    !$OMP ATOMIC
                    eh_primo(n) = eh_primo(n) .neqv. .true.
                end if
            end do
        end do
        !$OMP END PARALLEL DO

        do s = 5, int(sqrt(real(limite, 8)))
            if (eh_primo(s)) then
                n = s*s
                do x = n, limite, n
                    eh_primo(x) = .false.
                end do
            end if
        end do

        if (limite >= 2) eh_primo(2) = .true.
        if (limite >= 3) eh_primo(3) = .true.
        if (limite >= 1) eh_primo(1) = .false.

        call cpu_time(t2)
        
        print *, "Tempo total de CPU:", t2 - t1, "segundos"
        print *, "Primos encontrados:", count(eh_primo, kind=8)

        deallocate(eh_primo)
    end subroutine executar_atkin
end module mod_crivo

program main
    use mod_crivo
    implicit none
    integer(kind=8) :: limite_usuario
    read(*,*) limite_usuario
    call executar_atkin(limite_usuario)
end program main