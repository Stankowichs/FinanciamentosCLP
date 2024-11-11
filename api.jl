using HTTP
include("acompanhar.jl")
include("renegociar.jl")
include("requisitar.jl")
include("simulacao.jl")

function handle_request(req::HTTP.Request)
    println("Metodo: ", req.method)
    println("Target: ", req.target)
    body = String(req.body)
    println("Corpo da Requisição: ", body)

    if req.method == "GET" && startswith(req.target, "/acompanhar")
        # Separar o caminho do endpoint dos parâmetros de query
        uri = HTTP.URIs.URI(req.target)
        query_params = HTTP.URIs.queryparams(uri)
        println("Parâmetros de Query: ", query_params)
        
        # Verificar se o parâmetro 'cpf' está presente
        if haskey(query_params, "cpf")
            cpf_cliente = query_params["cpf"]
            println("CPF Cliente: ", cpf_cliente)
            resultado = acompanhar_financiamento(cpf_cliente)
            return HTTP.Response(200, resultado)
        else
            return HTTP.Response(400, "Parâmetro 'cpf' não encontrado")
        end
    elseif req.method == "POST" && req.target == "/renegociar"
        try
            data = JSON.parse(body)
            println("Dados Recebidos: ", data)

            resultado = renegociar(data["cpf"], data["novos_juros"], data["novo_prazo"], data["nova_renda"])
            println("Resultado da Renegociação: ", resultado)
            if resultado isa String
                return HTTP.Response(400, resultado)  # Retorna a mensagem de erro
            else
                return HTTP.Response(200, resultado)  # Retorna o JSON com os dados atualizados
            end
        catch e
            println("Erro ao processar requisição: ", e)
            return HTTP.Response(400, "Erro ao processar dados")
        end
    elseif req.method == "POST" && req.target == "/requisitar"
        try
            data = JSON.parse(body)
            println("Dados Recebidos: ", data)

            resultado = requisitar(data["prazo"], data["valor_solicitado"], data["valor_entrada"], data["cpf"], data["tipo_financiamento"])
            println("Resultado da Requisição: ", resultado)
            if resultado isa String
                return HTTP.Response(400, resultado)  # Retorna a mensagem de erro
            else
                return HTTP.Response(200, resultado)  # Retorna o JSON com os dados do financiamento
            end
        catch e
            println("Erro ao processar requisição: ", e)
            return HTTP.Response(400, "Erro ao processar dados")
        end
    elseif req.method == "POST" && req.target == "/simulacao"
        try
            data = JSON.parse(body)
            println("Dados Recebidos: ", data)

            resultado = simular_financiamento(
                data["prazo"],
                data["valor_inicial"],
                data["valor_entrada"],
                data["tipo_financiamento"]
            )
            println("Resultado da Simulação: ", resultado)
            return HTTP.Response(200, resultado)
        catch e
            println("Erro ao processar requisição: ", e)
            return HTTP.Response(400, JSON.json(Dict("erro" => "Erro ao processar dados")))
        end
    else
        return HTTP.Response(404, "Endpoint não encontrado")
    end
end

# Iniciar o servidor HTTP
HTTP.serve(handle_request, "0.0.0.0", 8080)
