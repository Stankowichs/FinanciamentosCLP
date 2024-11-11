using LibPQ
using JSON

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=Emnlefn01")

# Função de requisição de financiamento
function requisitar(prazo::Int, valor_solicitado::Float64, valor_entrada::Float64, CPF_cliente::String, tipo_financiamento::String)
    try
        # Verificar se o CPF existe no banco de dados
        cpf_result = execute(conn, "SELECT CPF FROM clientes WHERE CPF = '$CPF_cliente'")
        if isempty(cpf_result)
            return JSON.json(Dict("erro" => "CPF inválido"))
        end

        # Definir a taxa de juros com base no tipo de financiamento
        taxa_juros = 0.0
        if tipo_financiamento == "imobiliário"
            taxa_juros = 1.0
        elseif tipo_financiamento == "estudantil"
            taxa_juros = 0.3
        elseif tipo_financiamento == "veiculo"
            taxa_juros = 1.5
        elseif tipo_financiamento == "equipamento"
            taxa_juros = 1.3
        else
            return JSON.json(Dict("erro" => "Tipo de financiamento inválido"))
        end
        taxa_juros_decimal = taxa_juros / 100

        # Calcular o valor do financiamento e a parcela mensal
        valor_financiamento = valor_solicitado - valor_entrada
        parcela_mensal = (valor_financiamento * taxa_juros_decimal) / (1 - (1 + taxa_juros_decimal)^(-prazo))
        montante_total = parcela_mensal * prazo
        status = "Aprovado"
        meses_em_atraso = 0

        println("inserindo no banco de dados ", CPF_cliente, " ", valor_solicitado, " ", valor_entrada, " ", prazo, " ", tipo_financiamento, " ", taxa_juros, " ", parcela_mensal, " ", status, " ", montante_total, " ", meses_em_atraso, " ", montante_total)
        # Inserir a requisição no banco de dados, se aprovada
        execute(conn, """
        INSERT INTO financiamentos_atuais (CPF_cliente, valor_solicitado, valor_entrada, prazo, tipo_financiamento, taxa_juros, valor_parcela, status, montante_total, meses_em_atraso, saldo_devedor)
        VALUES ('$CPF_cliente', '$valor_solicitado', '$valor_entrada', '$prazo', '$tipo_financiamento', '$taxa_juros', '$parcela_mensal', '$status', '$montante_total', '$meses_em_atraso', '$montante_total')
    """)
    println("inserido no banco de dados ", CPF_cliente, " ", valor_solicitado, " ", valor_entrada, " ", prazo, " ", tipo_financiamento, " ", taxa_juros, " ", parcela_mensal, " ", status, " ", montante_total, " ", meses_em_atraso, " ", montante_total)

        # Retornar JSON com os detalhes do financiamento
        return JSON.json(Dict(
            "cpf_cliente" => CPF_cliente,
            "valor_solicitado" => valor_solicitado,
            "valor_entrada" => valor_entrada,
            "prazo" => prazo,
            "tipo_financiamento" => tipo_financiamento,
            "taxa_juros" => taxa_juros,
            "valor_parcela" => parcela_mensal,
            "status" => status,
            "montante_total" => montante_total
        ))
    catch e
        println("Erro ao processar requisição: ", e)
        return JSON.json(Dict("erro" => "Erro ao processar requisição"))
    end
end
requisitar(24, 50000.0, 5000.0, "12332112332", "veiculo")
# Fechar a conexão com o banco de dados
close(conn)
