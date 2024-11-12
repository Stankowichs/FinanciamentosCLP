using LibPQ
using JSON

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=Emnlefn01")

function acompanhar_financiamento(CPF_cliente::String)
    # Verificar se o CPF existe no banco de dados
    cpf_result = execute(conn, "SELECT CPF FROM clientes WHERE CPF = '$CPF_cliente' ")
    if isempty(cpf_result)
        return JSON.json(Dict("erro" => "CPF inválido"))
    end

    # Consulta SQL de junção das tabelas financiamentos e clientes
    query = raw"""
    SELECT c.nome, c.cpf, f.valor_solicitado, f.prazo, f.taxa_juros, f.valor_parcela, f.status, f.montante_total, f.saldo_devedor, f.tipo_financiamento 
    FROM clientes c
    JOIN financiamentos_atuais f ON c.cpf = f.cpf_cliente
    WHERE c.cpf = $1
    """

    # Executar a consulta com CPF como parâmetro
    result_cpf = execute(conn, "SELECT cpf_cliente FROM financiamentos_atuais WHERE cpf_cliente = '$CPF_cliente' ")
    if isempty(result_cpf)
        return JSON.json(Dict("erro" => "Cliente nao possui financiamento"))
    end
    
    # Criar uma lista para armazenar os resultados
    resultados = []

    # Adicionar os resultados à lista
    result = execute(conn, query, [CPF_cliente])
    for row in result
        push!(resultados, Dict(
            "nome" => row[1],
            "cpf" => row[2],
            "valor_solicitado" => row[3],
            "prazo" => row[4],
            "taxa_juros" => row[5],
            "valor_parcela" => row[6],
            "status" => row[7],
            "montante_total" => row[8],
            "saldo_devedor" => row[9],
            "tipo_financiamento" => row[10]
        ))
    end

    # Retornar os resultados como JSON
    return JSON.json(resultados)
end

# Fechar a conexão com o banco de dados
close(conn)
