using LibPQ

# Conexão com o banco de dados
conn = LibPQ.Connection("host=localhost dbname=financiamentos user=postgres password=736904")

function acompanhar_financiamento(CPF_cliente::String)
    # Verificar se o CPF existe no banco de dados
    cpf_result = execute(conn, "SELECT CPF FROM clientes WHERE CPF = '$CPF_cliente' ")
    if isempty(cpf_result)
        return "CPF inválido"
    end

    # Extrair o valor do CPF da consulta
    cpf = cpf_result[1, 1]  # Acessa a primeira linha e primeira coluna

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
        return "Cliente não possui financiamento"
    end
    
    # Imprimir o resultado do financiamento do cliente
    result = execute(conn, query, [cpf])
    for row in result
        println("Nome: $(row[1]), CPF: $(row[2])")
        println("Valor Solicitado: $(row[3]), Prazo: $(row[4]) meses, Taxa de Juros: $(row[5])% a.m")
        println("Tipo do financiamento: $(row[10])")
        println("Valor da Parcela: $(row[6])")
        println("Status do Financiamento: $(row[7])")
        println("Total a ser pago: $(row[8]), Saldo devedor: $(row[9])")
    end
    return "Consulta concluída"
end

# Chamando a função com um CPF de exemplo
resultado = acompanhar_financiamento("0987654321")
println(resultado)

# Fechar a conexão com o banco de dados
close(conn)
