program main
    use mod_crivo
    implicit none
    integer(kind=8) :: limite_usuario

    print *, ">>> CALCULADORA DE PRIMOS (ATKIN) <<<"
    print *, "Digite o valor limite (ex: 1000000):"
    read(*,*) limite_usuario

    call executar_atkin(limite_usuario)

    print *, ""
    print *, "Pressione ENTER para sair..."
    read(*,*) ! Isso segura a janela aberta
end program main