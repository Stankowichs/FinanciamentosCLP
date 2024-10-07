struct Cliente
    CPF::String
    nome::String
    renda::Float64
end

function simular_financiamento(prazo::Int, valor_inicial::Float64, taxa_juros::Float64)
    if prazo < 1
        error("O prazo deve ser positivo, e maior ou igual à 1")
    end
    if taxa_juros < 0 
        error("O juros não pode ser negativo")
    end

    juros_totais = valor_inicial * taxa_juros * (prazo/12)
    valor_total = valor_inicial + juros_totais
    valor_mensal = valor_total / prazo
    println("O valor total sera de ", valor_total, " reais")
    println("O valor pago mensalmente será de ", valor_mensal, " reais")
end

# function solicitar_financiamento(Cliente, prazo::int, valor::Float64, taxa_juros::Float64)
# end
simular_financiamento(24, 12000.0, 0.02)