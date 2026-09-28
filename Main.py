def menu():
    while True:
        print("--------------------Menu--------------------")
        print(
        "1. Logar\n" \
        "2. Cadastrar\n" \
        "3. Total gasto\n"
        "4. ")
        print("--------------------------------------------")

        opcao = int(input("Escolha sua opção: "))

        if opcao == 1:
            print("Login")
        elif opcao == 2:
            print("Cadastro")
        elif opcao == 3:
            print("Calculando total")
            break
        else:
            print("Opção Inválida")

menu()
