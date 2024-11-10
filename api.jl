using HTTP
include("acompanhar.jl")
include("renegociar.jl")

function handle_request(req::HTTP.Request)
    println("Metodo: ", req.method)
    println("Target: ", req.target)
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
        # Parsear o corpo do request como JSON
        body = String(req.body)
        data = JSON.parse(body)
        resultado = renegociar(data["cpf"], data["novos_juros"], data["novo_prazo"], data["nova_renda"])
        if resultado == 1
            return HTTP.Response(200, "Renegociação feita com sucesso!")
        else
            return HTTP.Response(400, "Renegociação negada!")
        end
    else
        return HTTP.Response(404, "Endpoint não encontrado")
    end
end

# Iniciar o servidor HTTP
HTTP.serve(handle_request, "0.0.0.0", 8080)
