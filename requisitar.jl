using LibPQ

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=736904")

# Função para validar a renda do cliente em relação à parcela
function validar_cliente(renda::Float64, parcela::Float64)
    return parcela <= (renda * 0.3)
end

# Função de requisição de financiamento
function requisitar(prazo::Int, valor_solicitado::Float64, valor_entrada::Float64, CPF_cliente::String, tipo_financiamento::String)
    # Verificar se o CPF existe no banco de dados
    cpf_result = execute(conn, "SELECT CPF FROM clientes WHERE CPF = '$CPF_cliente' ")
    cpf_cliente = cpf_result[1, 1]
    println(cpf_result)
    if isempty(cpf_result)
        return "CPF inválido"
    end

    # Definir a taxa de juros com base no tipo de financiamento
    taxa_juros = 0.0
    if tipo_financiamento == "imobiliário"
        taxa_juros = 1.0
    elseif tipo_financiamento == "estudantil"
        taxa_juros = 0.3
    elseif tipo_financiamento == "veículo"
        taxa_juros = 1.5
    elseif tipo_financiamento == "equipamento"
        taxa_juros = 1.3
    else
        return "Tipo de financiamento inválido"
    end
    taxa_juros_decimal = taxa_juros / 100

    # Calcular o valor do financiamento e a parcela mensal
    valor_financiamento = valor_solicitado - valor_entrada
    prazo_meses = prazo * 12  # assumindo que o prazo está em anos
    parcela_mensal = (valor_financiamento * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo_meses) / ((1 + taxa_juros_decimal)^prazo_meses - 1)

    # Obter a renda do cliente para validação
    renda_result = execute(conn, "SELECT renda FROM clientes WHERE CPF = '$CPF_cliente' ")
    renda_cliente = renda_result[1, 1]  # Obter a renda da primeira linha do resultado

    # Validar a renda do cliente em relação à parcela mensal
    if !validar_cliente(renda_cliente, parcela_mensal)
        return "Cliente não aprovado para o financiamento"
    end

    montante_total = parcela_mensal * prazo
    status = "Aprovado"
    #Inserir a requisição no banco de dados, se aprovada
    execute(conn, """
        INSERT INTO financiamentos_atuais (CPF_cliente, valor_solicitado, valor_entrada, prazo, tipo_financiamento, taxa_juros, valor_parcela, status, montante_total, meses_em_atraso, saldo_devedor)
        VALUES ('$CPF_cliente', '$valor_solicitado', '$valor_entrada', '$prazo', '$tipo_financiamento', '$taxa_juros', '$parcela_mensal', '$status', '$montante_total', '$prazo', '$montante_total')
    """)
    return "Financiamento aprovado e registrado no banco de dados"
end

# Exemplo de requisição de financiamento
println(requisitar(2, 10000.0, 2000.0, "0987654321", "imobiliário"))

# Fechar a conexão com o banco de dados
close(conn)
