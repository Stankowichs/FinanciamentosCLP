using Printf

function validar_cliente(renda::Float64, parcela::Float64)
    if parcela > (renda * 0.3)
        error("A parcela deve ser menor ou igual a 30% da renda do cliente\n")
    end
end 
 
function simular_financiamento(prazo::Int, valor_inicial::Float64, taxa_juros::Float64, valor_entrada::Float64, renda_cliente::Float64)
    if prazo < 1
        error("O prazo deve ser positivo e maior ou igual a 1\n")
    end
    if taxa_juros < 0 
        error("A taxa de juros não pode ser negativa\n")
    end

    #Calculo do juros e parcela mensal de acordo com a formula usada pelo banco central
    taxa_juros_decimal = taxa_juros / 100  
    valor_bruto = (valor_inicial - valor_entrada)
    parcela_mensal = (valor_bruto * taxa_juros_decimal * (1 + taxa_juros_decimal)^prazo) / ((1 + taxa_juros_decimal)^prazo - 1)
    valor_total = parcela_mensal * prazo
    juros_total = valor_total - valor_bruto
    
    validar_cliente(renda_cliente, parcela_mensal)
    
    @printf("O valor total será de %.2f reais\n", valor_total)
    @printf("O valor pago mensalmente será de %.2f\n", parcela_mensal)
    @printf("O valor do juros pago é de %.2f\n", juros_total)
end
