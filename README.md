# OxeBanking: Controle de Financiamentos  

**Universidade Federal de Alagoas (UFAL)**  
*Projeto desenvolvido para a disciplina de **Conceitos de Linguagem de Programação***

Este projeto é parte de uma iniciativa maior chamada **OxeBanking**, um sistema completo para gerenciamento de operações bancárias, onde cada funcionalidade é implementada em uma linguagem de programação diferente. A seção aqui descrita se concentra no **controle básico de financiamentos**, implementada em **Julia** e conectada a um banco de dados **PostgreSQL**.

---

## 🔍 **Visão Geral**

O módulo de **controle de financiamentos** permite:  
- **Gerenciar financiamentos** com um sistema local de banco de dados.  
- **Simular condições financeiras** e **acompanhar informações** sobre financiamentos ativos.  
- **Conectar-se ao PostgreSQL** via configuração local no **PgAdmin4**.  
- Utilizar uma **API REST local**, criada com **Julia** e a biblioteca HTTP.jl, para interagir com o sistema.

Este módulo não inclui pré-requisitos para a aprovação de financiamentos, garantindo simplicidade e foco no fluxo funcional básico.

---

## ⚙️ **Configuração**

### Pré-requisitos  
1. **Julia** (versão 1.8 ou superior)  
2. **PostgreSQL** (configurado para uso local via **PgAdmin4**)  
3. Dependências de Julia:  
   - HTTP.jl  
   - JSON3.jl  
   - PostgreSQL.jl

  ---

**Desenvolvido por:**  

*Pedro André e Hugo Stankowich Souza*  
---

**Licença:**  
Este projeto é de uso acadêmico e possui finalidade educacional.  
