module mod_crivo
    implicit none

contains

    subroutine executar_atkin(limite)
        integer(kind=8), intent(in) :: limite
        logical(kind=1), allocatable :: eh_primo(:)
        integer(kind=8) :: x, y, n, s, x2, y2
        real(8) :: t1, t2
        
        character(len=8)  :: data_atual
        character(len=10) :: hora_atual
        character(len=100) :: nome_arquivo

        print *, "--- Iniciando Crivo de Atkin (Thread-Safe) ---"
        print *, "Limite:", limite
        
        allocate(eh_primo(limite))
        eh_primo = .false.

        call cpu_time(t1)

        ! 1. Marcar os candidatos usando as equações quadráticas
        ! Usamos .NEQV. .TRUE. para inverter o valor de forma atômica
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

        ! 2. Eliminar múltiplos de quadrados
        do s = 5, int(sqrt(real(limite, 8)))
            if (eh_primo(s)) then
                n = s*s
                do x = n, limite, n
                    eh_primo(x) = .false.
                end do
            end if
        end do

        ! 3. Ajuste final (Primos base e neutralização do 1)
        if (limite >= 2) eh_primo(2) = .true.
        if (limite >= 3) eh_primo(3) = .true.
        if (limite >= 1) eh_primo(1) = .false.

        call cpu_time(t2)
        
        print *, "Calculo concluido!"
        print *, "Tempo total de CPU:", t2 - t1, "segundos"
        print *, "Primos encontrados:", count(eh_primo, kind=8)

        ! --- BLOCO DE SALVAMENTO ---
        block
            integer(kind=8) :: u, i_64, contador_final, total_primos
            total_primos = count(eh_primo, kind=8)
            
            call date_and_time(date=data_atual, time=hora_atual)
            nome_arquivo = "data/resumo_" // data_atual // "_" // hora_atual(1:6) // ".txt"
            
            open(newunit=u, file=trim(nome_arquivo), status='replace')
            
            write(u, '(A, I0)') "Limite processado: ", limite
            write(u, '(A, I0)') "Total de primos encontrados: ", total_primos
            write(u, '(A, F10.4, A)') "Tempo de execucao: ", (t2 - t1), " segundos"
            write(u, '(A)') "-----------------------------------------"

            if (limite <= 1000000) then
                do i_64 = 1, limite
                    if (eh_primo(i_64)) write(u, '(I0)') i_64
                end do
            else
                contador_final = 0
                do i_64 = limite, 1, -1
                    if (eh_primo(i_64)) then
                        write(u, '(I0)') i_64
                        contador_final = contador_final + 1
                    end if
                    if (contador_final >= 100) exit
                end do
            end if
            close(u)
            print *, "Relatorio gerado em: ", trim(nome_arquivo)
        end block

        deallocate(eh_primo)
        
    end subroutine executar_atkin

end module mod_crivo