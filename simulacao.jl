using Printf
using LibPQ

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=736904")

# Consultar dados na tabela "clientes"
nome_cliente = "Pedro Andre"
result = execute(conn, "SELECT * FROM clientes WHERE nome = '$nome_cliente' ")

# Loop para printar todos os resultados
for row in result
    println("ID: $(row[1]), Nome: $(row[2]), CPF: $(row[3]), Renda: $(row[4])")
end

# Função para validar a renda do cliente em relação à parcela
function validar_cliente(renda::Float64, parcela::Float64)
    return parcela <= (renda * 0.3)
end

# Função para simular o financiamento
function simular_financiamento(prazo::Int, valor_inicial::Float64, taxa_juros::Float64, valor_entrada::Float64, CPF_cliente::String)
    if prazo < 1
        return "O prazo deve ser positivo e maior ou igual a 1"
    end
    if taxa_juros < 0
        return "A taxa de juros não pode ser negativa"
    end

    # Consultar a renda do cliente
    renda_result = execute(conn, "SELECT renda FROM clientes WHERE CPF = '$CPF_cliente' ")

    # Verifica se o cliente foi encontrado e pega a renda
    if isempty(renda_result)
        return "Cliente não encontrado."
    end

    renda_cliente = renda_result[1, 1]  # Obter a renda do primeiro resultado
    println("Renda cliente: $(renda_cliente)")

    # Cálculo do juros e parcela mensal
    taxa_juros_decimal = taxa_juros / 100
    valor_bruto = valor_inicial - valor_entrada
    parcela_mensal = (valor_bruto * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    juros_total = valor_total - valor_bruto

    # Validação do cliente
    if !validar_cliente(renda_cliente, parcela_mensal)
        return "Cliente não aprovado para o financiamento"
    end

    return valor_total, parcela_mensal, juros_total
end

# Simulação do financiamento
resultado = simular_financiamento(24, 10000.0, 2.0, 0.0, "1234567890")
println(resultado)

# Fechar a conexão
close(conn)
