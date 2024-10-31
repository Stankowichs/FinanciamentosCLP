using LibPQ

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=736904")

function acompanhar_financiamento(CPF_cliente::String)
    if isempty(CPF_cliente)
        return "CPF inválido"
    end

    # comandos sql de junção da tabela financiamentos e clientes
    query = raw"""
    SELECT c.nome, c.cpf, f.valor_solicitado, f.prazo, f.taxa_juros, f.valor_parcela, f.data_inicio, f.data_termino, f.status
    FROM clientes c
    JOIN financiamentos f ON c.id_cliente = f.id_cliente
    WHERE c.cpf = $1
    """

    # cpf como parametro para a busca 
    result = execute(conn, query, [CPF_cliente])
    
    if isempty(result)
        return "Cliente não possui financiamento ou não foi encontrado."
    end

    # imprime o resultado do financiamento do cliente
    for row in result
        println("Nome: $(row[:nome]), CPF: $(row[:cpf])")
        println("Valor Solicitado: $(row[:valor_solicitado]), Prazo: $(row[:prazo]) meses, Taxa de Juros: $(row[:taxa_juros])%")
        println("Valor da Parcela: $(row[:valor_parcela]), Data Início: $(row[:data_inicio]), Data Término: $(row[:data_termino])")
        println("Status do Financiamento: $(row[:status])")
    end
end

# Chamando a função com um CPF de exemplo
resultado = acompanhar_financiamento("1234567890")
println(resultado)

# Fechando a conexão com o banco de dados
close(conn)
