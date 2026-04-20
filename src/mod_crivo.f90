module mod_crivo
    implicit none

contains

    subroutine executar_atkin(limite)
        integer(kind=8), intent(in) :: limite
        logical, allocatable :: eh_primo(:)
        integer(kind=8) :: x, y, n
        real(8) :: t1, t2

        print *, "Iniciando Crivo para limite:", limite
        
        ! Alocação dinâmica (Usa seus 20GB de RAM)
        allocate(eh_primo(limite))
        eh_primo = .false.

        call cpu_time(t1)

        ! --- INÍCIO DO ALGORITMO PARALELIZADO ---
        !$OMP PARALLEL DO PRIVATE(x, y, n) SHARED(eh_primo)
        do x = 1, int(sqrt(real(limite)))
            do y = 1, int(sqrt(real(limite)))
                
                ! Parte da lógica de Atkin (Exemplo simplificado de um dos passos)
                n = 4*x**2 + y**2
                if (n <= limite .and. (mod(n, 12) == 1 .or. mod(n, 12) == 5)) then
                    eh_primo(n) = .not. eh_primo(n)
                end if
                
                ! (Os outros passos do Atkin entram aqui...)
            end do
        end do
        !$OMP END PARALLEL DO
        ! --- FIM DO ALGORITMO ---

        call cpu_time(t2)
        print *, "Tempo de processamento (CPU):", t2 - t1, "segundos"

        deallocate(eh_primo)
    end subroutine executar_atkin

end module mod_crivo