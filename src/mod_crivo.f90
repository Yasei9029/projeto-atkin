module mod_crivo
    use omp_lib
    implicit none
    character(len=250), save :: pasta_execucao = ""

contains

    subroutine executar_atkin(limite_usuario)
        integer(kind=8), intent(inout) :: limite_usuario
        
        integer(kind=8), parameter :: TAMANHO_BLOCO = 10000000_8
        integer(kind=8), allocatable :: primos_base(:)
        integer(kind=8) :: limite_raiz, num_primos_base
        integer(kind=8) :: qtd_blocos, b, bloco_inicial
        integer(kind=8) :: total_primos, primos_no_bloco
        integer(kind=8) :: limite_inf_glob, limite_sup_glob
        
        integer(kind=8) :: t_rate, t_start, t_end
        real(8) :: tempo_real
        
        character(len=8)  :: data_atual
        character(len=10) :: hora_atual
        character(len=300) :: nome_arquivo
        character(len=350) :: comando_mkdir
        character(len=1)  :: opcao_chk, opcao_exp
        integer :: u_chk, u_glob, status_io
        logical :: existe_chk, existe_glob

        print *, "--- Iniciando Crivo de Atkin Segmentado ---"
        
        bloco_inicial = 0_8
        total_primos = 0_8
        limite_inf_glob = 0_8
        limite_sup_glob = limite_usuario
        
        inquire(file="crivo.chk", exist=existe_chk)
        
        if (existe_chk) then
            print *, "[CHECKPOINT] Arquivo de salvamento anterior detectado!"
            print *, "Deseja retomar o calculo anterior? (S/N):"
            read(*,*) opcao_chk
            if (opcao_chk == 'S' .or. opcao_chk == 's') then
                open(newunit=u_chk, file="crivo.chk", &
                     form="unformatted", status="old")
                read(u_chk) limite_usuario, bloco_inicial, total_primos, &
                            pasta_execucao, limite_inf_glob, limite_sup_glob
                close(u_chk)
                print *, "[CHECKPOINT] Retomando a partir do bloco:", bloco_inicial
                print *, "[CHECKPOINT] Limite original:", limite_usuario
                print *, "[CHECKPOINT] Primos acumulados ate aqui:", total_primos
                goto 999
            else
                print *, "[CHECKPOINT] Iniciando novo calculo do zero."
                existe_chk = .false.
            end if
        end if

        inquire(file="C:\Users\Lenovo\OneDrive\Documentos\" // &
                     "projeto-atkin\data\progresso_global.dat", exist=existe_glob)
        if (existe_glob) then
            open(newunit=u_glob, file="C:\Users\Lenovo\OneDrive\Documentos\" // &
                 "projeto-atkin\data\progresso_global.dat", &
                 form="unformatted", status="old")
            read(u_glob) limite_inf_glob
            close(u_glob)
            print *, "[EXPANSAO] Detectado calculo previo ate o limite de:", &
                     limite_inf_glob
            print *, "Deseja EXPANDIR a partir deste ponto? (S/N):"
            read(*,*) opcao_exp
            if (opcao_exp == 'S' .or. opcao_exp == 's') then
                limite_sup_glob = limite_usuario
                if (limite_sup_glob <= limite_inf_glob) then
                    print *, "[ERRO] Novo limite deve ser maior:", limite_inf_glob
                    return
                end if
                bloco_inicial = limite_inf_glob / TAMANHO_BLOCO
            else
                limite_inf_glob = 0_8
            end if
        end if

        call date_and_time(date=data_atual, time=hora_atual)
        if (limite_inf_glob > 0_8) then
            write(pasta_execucao, '(A, I0, A, I0, A)') &
                "C:\Users\Lenovo\OneDrive\Documentos\projeto-atkin\data\expand_de_", &
                limite_inf_glob, "_ate_", limite_sup_glob, "\"
        else
            pasta_execucao = "C:\Users\Lenovo\OneDrive\Documentos\" // &
                             "projeto-atkin\data\exec_" // &
                             data_atual // "_" // hora_atual(1:6) // "\"
        end if
        comando_mkdir = "mkdir """ // trim(pasta_execucao) // """"
        call execute_command_line(trim(comando_mkdir), wait=.true.)

999     continue

        print *, "Limite global:", limite_sup_glob
        print *, "Tamanho do bloco de memoria:", TAMANHO_BLOCO
        
        call system_clock(count_rate=t_rate)
        call system_clock(count=t_start)

        limite_raiz = int(sqrt(real(limite_sup_glob, 8)))
        call calcular_primos_base(limite_raiz, primos_base, num_primos_base)
        
        qtd_blocos = (limite_sup_glob + TAMANHO_BLOCO - 1) / TAMANHO_BLOCO
        
        if (bloco_inicial == 0_8) then
            if (limite_sup_glob >= 2) total_primos = total_primos + 1
            if (limite_sup_glob >= 3) total_primos = total_primos + 1
            if (limite_sup_glob >= 5) total_primos = total_primos + 1
        end if

        print *, "Quantidade total de blocks:", qtd_blocos
        print *, "Processando blocos de forma paralela..."

        !$OMP PARALLEL DO REDUCTION(+:total_primos) &
        !$OMP PRIVATE(b, primos_no_bloco, u_chk) SCHEDULE(DYNAMIC, 1)
        do b = bloco_inicial, qtd_blocos - 1
            call processar_bloco_atkin(b, TAMANHO_BLOCO, limite_sup_glob, &
                                       primos_base, num_primos_base, primos_no_bloco)
            total_primos = total_primos + primos_no_bloco
            
            if (omp_get_thread_num() == 0) then
                open(newunit=u_chk, file="crivo.chk", &
                     form="unformatted", status="replace")
                write(u_chk) limite_usuario, b + 1, total_primos, pasta_execucao, &
                             limite_inf_glob, limite_sup_glob
                close(u_chk)
            end if
        end do
        !$OMP END PARALLEL DO

        call system_clock(count=t_end)
        tempo_real = real(t_end - t_start, 8) / real(t_rate, 8)
        
        print *, "-----------------------------------------"
        print *, "Tempo REAL de execucao (Relogio):", tempo_real, "segundos"
        print *, "Primos encontrados neste intervalo:", total_primos

        open(newunit=u_chk, file="crivo.chk", status="old", iostat=status_io)
        if (status_io == 0) close(u_chk, status="delete")

        open(newunit=u_glob, file="C:\Users\Lenovo\OneDrive\Documentos\" // &
             "projeto-atkin\data\progresso_global.dat", &
             form="unformatted", status="replace")
        write(u_glob) limite_sup_glob
        close(u_glob)

        block
            integer(kind=8) :: u
            nome_arquivo = trim(pasta_execucao) // "resumo_final.txt"
            
            open(newunit=u, file=trim(nome_arquivo), status='replace', iostat=status_io)
            if (status_io == 0) then
                write(u, '(A, I0)') "Limite inferior do intervalo: ", limite_inf_glob
                write(u, '(A, I0)') "Limite superior processado: ", limite_sup_glob
                write(u, '(A, I0)') "Total de primos encontrados: ", total_primos
                write(u, '(A, F10.4, A)') "Tempo REAL de execucao: ", tempo_real
                close(u)
                print *, "Relatorio gerado em: ", trim(nome_arquivo)
            end if
        end block

        if (allocated(primos_base)) deallocate(primos_base)
        
    end subroutine executar_atkin
    
    subroutine processar_bloco_atkin(id_bloco, tam_bloco, limite_global, &
                                     primos_base, n_primos_base, contagem)
        integer(kind=8), intent(in) :: id_bloco, tam_bloco, limite_global, n_primos_base
        integer(kind=8), intent(in) :: primos_base(n_primos_base)
        integer(kind=8), intent(out) :: contagem
        
        logical(kind=1), allocatable :: bloco(:)
        integer(kind=8), allocatable :: buffer_primos(:)
        integer(kind=8) :: low, high, x, y, n, x2, i, p, p2, start_multiplo, idx_buf
        integer :: u_dados, status_io
        character(len=400) :: arq_dados
        
        low = id_bloco * tam_bloco
        high = min(low + tam_bloco - 1, limite_global)
        contagem = 0_8
        
        if (low > limite_global) return
        
        allocate(bloco(0:high-low))
        allocate(buffer_primos(tam_bloco / 10))
        bloco = .false.
        idx_buf = 0
        
        do x = 1, int(sqrt(real(high, 8)))
            x2 = 4_8 * x * x
            if (x2 >= high) exit
            do y = 1, int(sqrt(real(high - x2, 8))), 2
                n = x2 + y * y
                if (n >= low .and. n <= high) then
                    if (mod(n, 12) == 1 .or. mod(n, 12) == 5) then
                        bloco(n - low) = .not. bloco(n - low)
                    end if
                end if
            end do
        end do
        
        do x = 1, int(sqrt(real(high, 8))), 2
            x2 = 3_8 * x * x
            if (x2 >= high) exit
            do y = 2, int(sqrt(real(high - x2, 8))), 2
                n = x2 + y * y
                if (n >= low .and. n <= high) then
                    if (mod(n, 12) == 7) then
                        bloco(n - low) = .not. bloco(n - low)
                    end if
                end if
            end do
        end do
        
        do x = 1, int(sqrt(real(high, 8)))
            x2 = 3_8 * x * x
            do y = x - 1, 1, -2
                n = x2 - y * y
                if (n >= low .and. n <= high) then
                    if (mod(n, 12) == 11) then
                        bloco(n - low) = .not. bloco(n - low)
                    end if
                end if
                if (n > high) exit
            end do
        end do
        
        do i = 1, n_primos_base
            p = primos_base(i)
            p2 = p * p
            if (p2 > high) exit
            
            start_multiplo = ((low + p2 - 1) / p2) * p2
            if (start_multiplo < p2) start_multiplo = p2
            
            do n = start_multiplo, high, p2
                if (n >= low) bloco(n - low) = .false.
            end do
        end do
        
        do n = max(6_8, low), high
            if (bloco(n - low)) then
                i = mod(n, 60)
                if (i==1 .or. i==7 .or. i==11 .or. i==13 .or. i==17 .or. &
                    i==19 .or. i==23 .or. i==29 .or. i==31 .or. i==37 .or. &
                    i==41 .or. i==43 .or. i==47 .or. i==49 .or. i==53 .or. &
                    i==59) then
                    contagem = contagem + 1
                    idx_buf = idx_buf + 1
                    buffer_primos(idx_buf) = n
                end if
            end if
        end do
        
        if (idx_buf > 0) then
            write(arq_dados, '(A, I0, A)') trim(pasta_execucao) // &
                                           "primos_bloco_", id_bloco, ".bin"
            open(newunit=u_dados, file=trim(arq_dados), form="unformatted", &
                 status="replace", iostat=status_io)
            if (status_io == 0) then
                write(u_dados) buffer_primos(1:idx_buf)
                close(u_dados)
            end if
        end if
        
        deallocate(bloco)
        deallocate(buffer_primos)
    end subroutine processar_bloco_atkin


    subroutine calcular_primos_base(raiz, vet_primos, total)
        integer(kind=8), intent(in) :: raiz
        integer(kind=8), allocatable, intent(out) :: vet_primos(:)
        integer(kind=8), intent(out) :: total
        
        logical(kind=1), allocatable :: crivo(:)
        integer(kind=8) :: i, j
        
        allocate(crivo(raiz))
        crivo = .true.
        total = 0
        
        do i = 2, int(sqrt(real(raiz, 8)))
            if (crivo(i)) then
                do j = i*i, raiz, i
                    crivo(j) = .false.
                end do
            end if
        end do
        
        do i = 2, raiz
            if (crivo(i)) total = total + 1
        end do
        
        allocate(vet_primos(total))
        j = 1
        do i = 2, raiz
            if (crivo(i)) then
                vet_primos(j) = i
                j = j + 1
            end if
        end do
        deallocate(crivo)
    end subroutine calcular_primos_base

end module mod_crivo
