using LibPQ
using Dates

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

function calcularData(data_antiga::String, prazo::Int)
    data_antiga + month(prazo)
end

# renegociar (novas condicoes)  --- as novas condicoes envolvem taxa de juros e prazo para pagar
function renegociar(id_cliente::Int, novos_juros::Float64, novo_prazo::Int, nova_renda::Float64)
    # pegar os dados do cliente
    id_cliente = execute(conn, "SELECT id_clientes FROM clientes WHERE CPF = '$id_cliente' ")

    # verificar se ha nao ha meses em atraso, se sim, nao renegociar
    meses_atraso = execute(conn, "SELECT meses_em_atraso FROM financiamentos_atuais WHERE id_clientes = '$id_cliente' ")
    renda_cliente = execute(conn, "SELECT renda FROM clientes WHERE id_clientes = '$id_cliente' ")

    if (meses_atraso == 0) 
        # verificar se a renda do cliente diminuiu, se nao, nao renegociar
        if (renda_cliente <= nova_renda)
            return "Seu perfil nao atende as condicoes de renegociacao!"
        end
    end
    
    saldo_devedor = execute(conn, "SELECT saldo_devedor FROM financiamentos_atuais WHERE id_clientes = '$id_cliente' ")
    montante_atual = execute(conn, "SELECT montante_total FROM financiamentos_atuais WHERE id_clientes = '$id_cliente' ")
    
    #calcular nova parcela
    result = calcular_parcela(novos_juros, saldo_devedor, novo_prazo)

    nova_parcela = result[0]
    novo_montante = result[1]

    # Validação do cliente
    if !validar_cliente(nova_renda, nova_parcela)
        return "Cliente não aprovado para o financiamento"
    end

    #calculo da data com novo prazo
    data_antiga = execute(conn, "SELECT data_termino FROM financiamentos_atuais WHERE id_clientes = '$id_clientes'")
    nova_data = calcularData(Date(data_antiga), novo_prazo)

    # calculo do novo saldo devedor
    total_pago = montante_atual - saldo_devedor
    saldo_devedor = novo_montante - total_pago

    # dar update na renda do cliente
    execute(conn, "UPDATE clientes SET renda = '$nova_renda' WHERE id_clientes = '$id_cliente'")

    # dar update das novas condicoes
    execute(conn, "UPDATE financiamentos_atuais SET prazo = '$novo_prazo', taxa_juros = '$novos_juros', 
    valor_parcela = '$nova_parcela', 
    data_termino = '$nova_data',
    montante_total = '$novo_montante',
    saldo_devedor = '$saldo_devedor',
    meses_em_atraso = 0
    WHERE id_clientes = '$id_cliente'")

    return 1
end
