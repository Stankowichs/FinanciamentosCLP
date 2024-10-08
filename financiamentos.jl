using Printf

struct Cliente
    CPF::String
    nome::String
    renda::Float64
end

function simular_financiamento(prazo::Int, valor_inicial::Float64, taxa_juros::Float64, valor_entrada::Float64)
    if prazo < 1
        error("O prazo deve ser positivo e maior ou igual a 1")
    end
    if taxa_juros < 0 
        error("A taxa de juros não pode ser negativa")
    end

    #Calculo do juros e parcela mensal de acordo com a formula usada pelo banco central
    taxa_juros_decimal = taxa_juros / 100  
    parcela_mensal = ((valor_inicial - valor_entrada) * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    juros_total = valor_total - valor_inicial

    @printf("O valor total será de %.2f reais\n", valor_total)
    @printf("O valor pago mensalmente será de %.2f\n", parcela_mensal)
    @printf("O valor do juros pago é de %.2f\n", juros_total)
end

simular_financiamento(24, 12000.0, 2.0, 1000.0)  # 2% ao mês
