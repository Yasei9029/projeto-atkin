module mod_crivo
    implicit none

contains

    subroutine executar_atkin(limite)
        integer(kind=8), intent(in) :: limite
        logical(kind=1), allocatable :: eh_primo(:) ! kind=1 economiza RAM
        integer(kind=8) :: x, y, n, s
        real(8) :: t1, t2

        print *, "--- Iniciando Crivo de Atkin ---"
        print *, "Limite:", limite
        
        allocate(eh_primo(limite))
        eh_primo = .false.

        call cpu_time(t1)

        ! 1. Marcar os candidatos usando as equações quadráticas
        !$OMP PARALLEL DO PRIVATE(x, y, n) SHARED(eh_primo) SCHEDULE(DYNAMIC)
        do x = 1, int(sqrt(real(limite)))
            do y = 1, int(sqrt(real(limite)))
                
                ! Equação 1: n = 4x² + y²
                n = 4*x**2 + y**2
                if (n <= limite .and. (mod(n, 12) == 1 .or. mod(n, 12) == 5)) then
                    eh_primo(n) = .not. eh_primo(n)
                end if

                ! Equação 2: n = 3x² + y²
                n = 3*x**2 + y**2
                if (n <= limite .and. mod(n, 12) == 7) then
                    eh_primo(n) = .not. eh_primo(n)
                end if

                ! Equação 3: n = 3x² - y²
                n = 3*x**2 - y**2
                if (x > y .and. n <= limite .and. mod(n, 12) == 11) then
                    eh_primo(n) = .not. eh_primo(n)
                end if
                
            end do
        end do
        !$OMP END PARALLEL DO

        ! 2. Eliminar múltiplos de quadrados (ex: 25, 49, 121...)
        do s = 5, int(sqrt(real(limite)))
            if (eh_primo(s)) then
                n = s**2
                do x = n, limite, n
                    eh_primo(x) = .false.
                end do
            end if
        end do

        ! 3. Adicionar os primos base
        if (limite >= 2) eh_primo(2) = .true.
        if (limite >= 3) eh_primo(3) = .true.

        call cpu_time(t2)
        
        print *, "Calculo concluido!"
        print *, "Tempo total de CPU:", t2 - t1, "segundos"
        
        ! Conta quantos primos foram encontrados
        print *, "Primos encontrados:", count(eh_primo)

        ! Aqui chamaremos o módulo de exportação depois
        deallocate(eh_primo)
        
    end subroutine executar_atkin

end module mod_crivo