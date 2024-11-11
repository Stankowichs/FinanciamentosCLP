using LibPQ
using JSON

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=Emnlefn01")


function calcular_parcela(taxa_juros::Float64, valor_bruto::Float64, prazo::Int)
    taxa_juros_decimal = taxa_juros / 100
    parcela_mensal = (valor_bruto * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    return parcela_mensal, valor_total
end

# renegociar (novas condicoes)  --- as novas condicoes envolvem taxa de juros e prazo para pagar
function renegociar(cpf_cliente::String, novos_juros::Float64, novo_prazo::Int, nova_renda::Float64)
    # Verificar se há meses em atraso
    # meses_atraso_result = execute(conn, "SELECT meses_em_atraso FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente'")
    # if isempty(meses_atraso_result) || meses_atraso_result[1, 1] > 0
    #     return JSON.json(Dict("erro" => "Seu perfil não atende as condições de renegociação devido a meses em atraso!"))
    # end

    # # Verificar se a renda do cliente diminuiu
    # renda_cliente_result = execute(conn, "SELECT renda FROM clientes WHERE cpf = '$cpf_cliente'")
    # if isempty(renda_cliente_result) || renda_cliente_result[1, 1] > nova_renda
    #     return JSON.json(Dict("erro" => "Seu perfil não atende as condições de renegociação devido à renda!"))
    # end

    # Obter saldo devedor e montante atual
    saldo_devedor_result = execute(conn, "SELECT saldo_devedor FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente'")
    montante_atual_result = execute(conn, "SELECT montante_total FROM financiamentos_atuais WHERE cpf_cliente = '$cpf_cliente'")
    if isempty(saldo_devedor_result) || isempty(montante_atual_result)
        return JSON.json(Dict("erro" => "Erro ao obter informações financeiras do cliente."))
    end

    saldo_devedor = Float64(saldo_devedor_result[1, 1])
    montante_atual = Float64(montante_atual_result[1, 1])

    # Calcular nova parcela
    nova_parcela, novo_montante = calcular_parcela(novos_juros, saldo_devedor, novo_prazo)



    # Calcular novo saldo devedor
    total_pago = montante_atual - saldo_devedor
    saldo_devedor = novo_montante - total_pago

    # Atualizar renda do cliente
    execute(conn, "UPDATE clientes SET renda = '$nova_renda' WHERE cpf = '$cpf_cliente'")

    # Atualizar condições do financiamento
    execute(conn, "UPDATE financiamentos_atuais SET prazo = '$novo_prazo', taxa_juros = '$novos_juros', 
    valor_parcela = '$nova_parcela', 
    montante_total = '$novo_montante',
    saldo_devedor = '$saldo_devedor',
    meses_em_atraso = 0
    WHERE cpf_cliente = '$cpf_cliente'")

    # Retornar JSON com as variáveis atualizadas
    return JSON.json(Dict(
        "cpf_cliente" => cpf_cliente,
        "novo_prazo" => novo_prazo,
        "novos_juros" => novos_juros,
        "nova_parcela" => nova_parcela,
        "novo_montante" => novo_montante,
        "saldo_devedor" => saldo_devedor,
        "nova_renda" => nova_renda
    ))
end
