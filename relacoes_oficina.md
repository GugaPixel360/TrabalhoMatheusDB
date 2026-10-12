# Relações do Banco de Dados - Oficina Mecânica

| Tabela Origem   | Tabela Destino      | Relação Numérica           | Campo de Ligação                             |
|:----------------|:--------------------|:---------------------------|:---------------------------------------------|
| clientes        | veiculos            | 1 : N (Um para Muitos)     | veiculos.fk_id_cliente                       |
| veiculos        | ordens_servico      | 1 : N (Um para Muitos)     | ordens_servico.fk_id_veiculo                 |
| mecanicos       | ordens_servico      | 1 : N (Um para Muitos)     | ordens_servico.fk_id_mecanico                |
| especialidades  | mecanicos           | 1 : N (Um para Muitos)     | mecanicos.fk_id_especialidade                |
| especialidades  | servicos            | 1 : N (Um para Muitos)     | servicos.fk_id_especialidade                 |
| servicos        | historico_precos    | 1 : N (Um para Muitos)     | historico_precos.fk_id_servico               |
| ordens_servico  | servicos_realizados | 1 : N (Um para Muitos)     | servicos_realizados.fk_id_ordem_servico      |
| servicos        | servicos_realizados | 1 : N (Um para Muitos)     | servicos_realizados.fk_id_servico            |
| ordens_servico  | servicos            | N : N (Muitos para Muitos) | Via tabela intermediária servicos_realizados |