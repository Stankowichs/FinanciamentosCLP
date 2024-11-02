using LibPQ

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=Emnlefn01")

# Função para validar a renda do cliente em relação à parcela
function validar_cliente(renda::Float64, parcela::Float64)
    return parcela <= (renda * 0.3)
end

function calcular_parcela(taxa_juros::Float64, valor_bruto::Float64, prazo::Int)
    taxa_juros_decimal = taxa_juros / 100
    parcela_mensal = (valor_bruto * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    return parcela_mensal, valor_total
end

# renegociar (novas condicoes)  --- as novas condicoes envolvem taxa de juros e prazo para pagar
function renegociar(cpf_cliente::String, novos_juros::Float64, novo_prazo::Int, nova_renda::Float64)

    # verificar se ha nao ha meses em atraso, se sim, nao renegociar
    meses_atraso = execute(conn, "SELECT meses_em_atraso FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente' ")
    renda_cliente = execute(conn, "SELECT renda FROM clientes WHERE cpf = '$cpf_cliente' ")

    if (meses_atraso == 0) 
        # verificar se a renda do cliente diminuiu, se nao, nao renegociar
        if (renda_cliente <= nova_renda)
            return "Seu perfil nao atende as condicoes de renegociacao!"
        end
    end
    
    saldo_devedor_result = execute(conn, "SELECT saldo_devedor FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente' ")
    saldo_devedor = Float64(saldo_devedor_result[1, 1])
    montante_atual_result = execute(conn, "SELECT montante_total FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente' ")
    montante_atual = Float64(montante_atual_result[1, 1])
    
    #calcular nova parcela
    nova_parcela, novo_montante = calcular_parcela(novos_juros, saldo_devedor, novo_prazo)

    # Validação do cliente
    if !validar_cliente(nova_renda, nova_parcela)
        return "Cliente não aprovado para o financiamento"
    end

    # calculo do novo saldo devedor
    total_pago = montante_atual - saldo_devedor
    saldo_devedor = novo_montante - total_pago

    # dar update na renda do cliente
    execute(conn, "UPDATE clientes SET renda = '$nova_renda' WHERE cpf = '$cpf_cliente'")

    # dar update das novas condicoes
    execute(conn, "UPDATE financiamentos_atuais SET prazo = '$novo_prazo', taxa_juros = '$novos_juros', 
    valor_parcela = '$nova_parcela', 
    montante_total = '$novo_montante',
    saldo_devedor = '$saldo_devedor',
    meses_em_atraso = 0
    WHERE cpf_cliente = '$cpf_cliente'")

    return 1
end

if renegociar("123456789", 1.8, 42, 25000.00) == 1
    println("Renegociacao feita com sucesso!")
else 
    println("Renegociacao negada!")
end
