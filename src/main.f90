program main
    use mod_crivo
    implicit none
    integer(kind=8) :: limite_usuario

    print *, "Digite o limite para busca de primos:"
    read *, limite_usuario

    call executar_atkin(limite_usuario)

end program main