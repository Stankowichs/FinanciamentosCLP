using JSON

# Função de simulação de financiamento
function simular_financiamento(prazo::Int, valor_inicial::Float64, valor_entrada::Float64, tipo_financiamento::String)
    if prazo < 1
        return JSON.
        json(Dict("erro" => "O prazo deve ser positivo e maior ou igual a 1"))
    end

    if tipo_financiamento == "imobiliario"
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
    valor_bruto = valor_inicial - valor_entrada
    parcela_mensal = (valor_bruto * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    juros_total = valor_total - valor_bruto

    return JSON.json(Dict(
        "valor_total" => valor_total,
        "parcela_mensal" => parcela_mensal,
        "juros_total" => juros_total,
        "tipo_financiamento" => tipo_financiamento
    ))
end
