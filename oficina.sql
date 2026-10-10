CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;

-- tabela clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_c INT AUTO_INCREMENT PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    endereco VARCHAR(255)
);


-- tabela veiculos
CREATE TABLE IF NOT EXISTS veiculos (
    id_v INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_cliente INT NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    placa VARCHAR(8) NOT NULL UNIQUE,

    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (fk_id_cliente)
        REFERENCES clientes(id_c)
);


-- tabela especialidades
CREATE TABLE IF NOT EXISTS especialidades (
    id_eps INT AUTO_INCREMENT PRIMARY KEY,
    qual VARCHAR(100) NOT NULL UNIQUE
);


-- tabela mecanicos 
CREATE TABLE IF NOT EXISTS mecanicos (
    id_m INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    fk_id_especialidade INT,

    CONSTRAINT fk_mecanico_especialidade
        FOREIGN KEY (fk_id_especialidade)
        REFERENCES especialidades(id_eps)
);


-- tabela servicos 
CREATE TABLE IF NOT EXISTS servicos (
    id_scs INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    fk_id_especialidade INT,

    CONSTRAINT chk_servico_valor
        CHECK (valor > 0),

    CONSTRAINT fk_servico_especialidade
        FOREIGN KEY (fk_id_especialidade)
        REFERENCES especialidades(id_eps)
);


-- tabela ordens de servico 
CREATE TABLE IF NOT EXISTS ordens_servico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_veiculo INT NOT NULL,
    fk_id_mecanico INT NOT NULL,
    fk_id_servico INT NOT NULL,
    data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aberta',

    CONSTRAINT chk_status_ordem
        CHECK (status IN ('aberta', 'em andamento', 'fechada')),

    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (fk_id_veiculo)
        REFERENCES veiculos(id_v),

    CONSTRAINT fk_os_mecanico
        FOREIGN KEY (fk_id_mecanico)
        REFERENCES mecanicos(id_m),

    CONSTRAINT fk_os_servico
        FOREIGN KEY (fk_id_servico)
        REFERENCES servicos(id_scs)
);


-- tabela historico de precos 
CREATE TABLE IF NOT EXISTS historico_precos (
    id_hp INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_servico INT NOT NULL,
    preco_anterior DECIMAL(10,2) NOT NULL,
    preco_novo DECIMAL(10,2) NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_historico_servico
        FOREIGN KEY (fk_id_servico)
        REFERENCES servicos(id_scs)
);


-- tabela servicos realizados 
CREATE TABLE IF NOT EXISTS servicos_realizados (
    id_sr INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_ordem_servico INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    fk_id_servico INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_realizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_servico_realizado_valor
        CHECK (valor > 0),

    CONSTRAINT fk_sr_ordem
        FOREIGN KEY (fk_id_ordem_servico)
        REFERENCES ordens_servico(id_os),

    CONSTRAINT fk_sr_servico
        FOREIGN KEY (fk_id_servico)
        REFERENCES servicos(id_scs)
);

-- inserts da parte 3

-- Inserções mínimas exigidas
INSERT INTO clientes (nome, email, cpf, endereco) VALUES
('Ana Silva', 'ana@email.com', '11111111111', 'Rua 1'),
('Bruno Dias', 'bruno@email.com', '22222222222', 'Rua 2'),
('Carlos Souza', 'carlos@email.com', '33333333333', 'Rua 3'),
('Daniela Ferreira', 'daniela@email.com', '44444444444', 'Rua 4'),
('Eduardo Gomes', 'eduardo@email.com', '55555555555', 'Rua 5'),
('Fernanda Helena', 'fernanda@email.com', '66666666666', 'Rua 6'),
('Gabriel Inácio', 'gabriel@email.com', '77777777777', 'Rua 7'),
('Heloisa Julia', 'heloisa@email.com', '88888888888', 'Rua 8'),
('Igor Kauã', 'igor@email.com', '99999999999', 'Rua 9'),
('Juliana Lima', 'juliana@email.com', '10101010101', 'Rua 10');

INSERT INTO especialidades (qual) VALUES
('Mecânica Geral'), ('Elétrica'), ('Injeção Eletrônica'), ('Suspensão e Freios');

INSERT INTO mecanicos (nome, fk_id_especialidade) VALUES
('João Mecânico', 1), ('Pedro Elétrico', 2), ('Lucas Injeção', 3), ('Marcos Suspensão', 4), ('Mateus Geral', 1);

INSERT INTO veiculos (fk_id_cliente, marca, modelo, ano, placa) VALUES
(1, 'Fiat', 'Palio', 2010, 'ABC-1234'), (1, 'Chevrolet', 'Onix', 2020, 'DEF-5678'),
(2, 'VW', 'Gol', 2015, 'GHI-9012'), (3, 'Ford', 'Ka', 2018, 'JKL-3456'),
(4, 'Renault', 'Kwid', 2021, 'MNO-7890'), (5, 'Hyundai', 'HB20', 2019, 'PQR-1234'),
(6, 'Toyota', 'Corolla', 2022, 'STU-5678'), (7, 'Honda', 'Civic', 2020, 'VWX-9012'),
(8, 'Jeep', 'Renegade', 2023, 'YZA-3456'), (9, 'Nissan', 'Kicks', 2021, 'BCD-7890'),
(10, 'Peugeot', '208', 2022, 'EFG-1234'), (10, 'Citroen', 'C3', 2023, 'HIJ-5678');

INSERT INTO servicos (descricao, valor, fk_id_especialidade) VALUES
('Troca de Óleo', 150.00, 1), ('Troca de Bateria', 400.00, 2),
('Limpeza de Bicos', 250.00, 3), ('Troca de Pastilhas', 200.00, 4),
('Alinhamento', 120.00, 4), ('Revisão Geral', 800.00, 1),
('Troca de Correia', 550.00, 1), ('Troca de Velas', 180.00, 2),
('Reparo Alternador', 350.00, 2), ('Diagnóstico', 100.00, 3);

INSERT INTO ordens_servico (fk_id_veiculo, fk_id_mecanico, status) VALUES
(1, 1, 'fechada'), (2, 2, 'aberta'), (3, 3, 'em andamento'), (4, 4, 'fechada'),
(5, 5, 'aberta'), (6, 1, 'em andamento'), (7, 2, 'fechada'), (8, 3, 'aberta'),
(9, 4, 'em andamento'), (10, 5, 'fechada');

INSERT INTO servicos_realizados (fk_id_ordem_servico, descricao, fk_id_servico, valor) VALUES
(1, 'Troca de Óleo', 1, 150.00), (1, 'Troca de Bateria', 2, 400.00),
(2, 'Limpeza de Bicos', 3, 250.00), (3, 'Troca de Pastilhas', 4, 200.00),
(4, 'Alinhamento', 5, 120.00), (5, 'Revisão Geral', 6, 800.00),
(6, 'Troca de Correia', 7, 550.00), (7, 'Troca de Velas', 8, 180.00),
(8, 'Reparo Alternador', 9, 350.00), (9, 'Diagnóstico', 10, 100.00),
(10, 'Troca de Óleo', 1, 150.00), (10, 'Alinhamento', 5, 120.00),
(1, 'Revisão Geral', 6, 800.00), (2, 'Troca de Correia', 7, 550.00), (3, 'Troca de Velas', 8, 180.00);

-- Exemplo UPDATE exigido
UPDATE clientes SET endereco = 'Rua Atualizada, 999' WHERE id_c = 1;

-- Exemplo DELETE exigido
INSERT INTO clientes (nome, email, cpf, endereco) VALUES ('Teste Excluir', 'excluir@email.com', '00000000000', 'Rua X');
DELETE FROM clientes WHERE cpf = '00000000000';




-- Consultas com inner join

-- Cliente + veículos

SELECT
    c.id_c,
    c.nome AS cliente,
    v.id_v,
    v.marca,
    v.modelo,
    v.ano,
    v.placa
FROM clientes c
INNER JOIN veiculos v
    ON c.id_c = v.fk_id_cliente
ORDER BY c.nome, v.marca, v.modelo;


-- Ordem de serviço + cliente + veículo

SELECT
    os.id_os,
    c.nome AS cliente,
    v.marca,
    v.modelo,
    v.placa,
    os.data_abertura,
    os.status
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.fk_id_veiculo = v.id_v
INNER JOIN clientes c
    ON v.fk_id_cliente = c.id_c
ORDER BY os.data_abertura DESC;


-- Ordem de serviço + mecânico

SELECT
    os.id_os,
    m.id_m,
    m.nome AS mecanico,
    os.data_abertura,
    os.data_fechamento,
    os.status
FROM ordens_servico os
INNER JOIN mecanicos m
    ON os.fk_id_mecanico = m.id_m
ORDER BY os.id_os;


-- Ordem de serviço + serviços realizados

SELECT
    os.id_os,
    os.data_abertura,
    os.status,
    sr.id_sr,
    sr.descricao AS servico_realizado,
    sr.valor,
    sr.data_realizacao
FROM ordens_servico os
INNER JOIN servicos_realizados sr
    ON os.id_os = sr.fk_id_ordem_servico
ORDER BY os.id_os, sr.data_realizacao;


-- =========================================================
-- ORDEM DE SERVIÇO COMPLETA
-- =========================================================

SELECT
    os.id_os,
    c.nome AS cliente,
    v.marca,
    v.modelo,
    v.placa,
    m.nome AS mecanico,
    sr.descricao AS servico,
    sr.valor,
    os.data_abertura,
    os.data_fechamento,
    os.status
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.fk_id_veiculo = v.id_v
INNER JOIN clientes c
    ON v.fk_id_cliente = c.id_c
INNER JOIN mecanicos m
    ON os.fk_id_mecanico = m.id_m
INNER JOIN servicos_realizados sr
    ON os.id_os = sr.fk_id_ordem_servico
ORDER BY os.data_abertura DESC, c.nome;


-- =========================================================
-- RELATÓRIO DE MECÂNICOS
-- =========================================================

SELECT
    m.id_m,
    m.nome AS mecanico,
    e.qual AS especialidade,
    COUNT(os.id_os) AS total_ordens,
    MAX(os.data_abertura) AS ultima_ordem
FROM mecanicos m
LEFT JOIN ordens_servico os
    ON m.id_m = os.fk_id_mecanico
LEFT JOIN especialidades e
    ON m.fk_id_especialidade = e.id_eps
GROUP BY
    m.id_m,
    m.nome,
    e.qual
ORDER BY total_ordens DESC, m.nome;


-- =========================================================
-- PROCEDURES
-- =========================================================

DELIMITER $$


-- Cadastrar cliente

DROP PROCEDURE IF EXISTS cadastrar_cliente$$

CREATE PROCEDURE cadastrar_cliente(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_endereco VARCHAR(255)
)
BEGIN

    IF EXISTS (
        SELECT 1
        FROM clientes
        WHERE email = p_email
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Email já cadastrado.';

    ELSE

        INSERT INTO clientes (
            nome,
            email,
            endereco
        )
        VALUES (
            p_nome,
            p_email,
            p_endereco
        );

    END IF;

END$$


-- Abrir ordem de serviço

DROP PROCEDURE IF EXISTS abrir_ordem$$

CREATE PROCEDURE abrir_ordem(
    IN p_id_veiculo INT,
    IN p_id_mecanico INT,
    IN p_id_servico INT,
    IN p_data_abertura DATETIME
)
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM veiculos
        WHERE id_v = p_id_veiculo
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Veículo não encontrado.';

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM mecanicos
        WHERE id_m = p_id_mecanico
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mecânico não encontrado.';

    ELSEIF NOT EXISTS (
        SELECT 1
        FROM servicos
        WHERE id_scs = p_id_servico
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Serviço não encontrado.';

    ELSE

        INSERT INTO ordens_servico (
            fk_id_veiculo,
            fk_id_mecanico,
            fk_id_servico,
            data_abertura
        )
        VALUES (
            p_id_veiculo,
            p_id_mecanico,
            p_id_servico,
            COALESCE(p_data_abertura, NOW())
        );

    END IF;

END$$


-- Alterar status da ordem

DROP PROCEDURE IF EXISTS alterar_status_ordem$$

CREATE PROCEDURE alterar_status_ordem(
    IN p_id_ordem INT,
    IN p_novo_status VARCHAR(20)
)
BEGIN

    IF NOT EXISTS (
        SELECT 1
        FROM ordens_servico
        WHERE id_os = p_id_ordem
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ordem de serviço não encontrada.';

    ELSEIF p_novo_status NOT IN (
        'aberta',
        'em andamento',
        'fechada'
    ) THEN

        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Status inválido.';

    ELSE

        UPDATE ordens_servico
        SET
            status = p_novo_status,
            data_fechamento =
                CASE
                    WHEN p_novo_status = 'fechada'
                        THEN COALESCE(data_fechamento, NOW())
                    ELSE NULL
                END
        WHERE id_os = p_id_ordem;

    END IF;

END$$


-- Relatório de um cliente

DROP PROCEDURE IF EXISTS relatorio_cliente$$

CREATE PROCEDURE relatorio_cliente(
    IN p_id_cliente INT
)
BEGIN

    SELECT
        c.id_c,
        c.nome,
        COUNT(DISTINCT os.id_os) AS quantidade_servicos,
        COALESCE(SUM(s.valor), 0) AS total_gasto
    FROM clientes c
    LEFT JOIN veiculos v
        ON c.id_c = v.fk_id_cliente
    LEFT JOIN ordens_servico os
        ON v.id_v = os.fk_id_veiculo
    LEFT JOIN servicos s
        ON os.fk_id_servico = s.id_scs
    WHERE c.id_c = p_id_cliente
    GROUP BY
        c.id_c,
        c.nome;

END$$


-- Total de clientes

DROP PROCEDURE IF EXISTS total_clientes$$

CREATE PROCEDURE total_clientes()
BEGIN

    SELECT COUNT(*) AS total_clientes
    FROM clientes;

END$$


-- Total de veículos

DROP PROCEDURE IF EXISTS total_veiculos$$

CREATE PROCEDURE total_veiculos()
BEGIN

    SELECT COUNT(*) AS total_veiculos
    FROM veiculos;

END$$


-- Métricas dos serviços

DROP PROCEDURE IF EXISTS metricas_servicos$$

CREATE PROCEDURE metricas_servicos()
BEGIN

    SELECT
        MAX(valor) AS servico_mais_caro,
        MIN(valor) AS servico_mais_barato,
        ROUND(AVG(valor), 2) AS preco_medio_servicos,
        SUM(valor) AS valor_total_servicos
    FROM servicos;

END$$

DELIMITER ;


-- =========================================================
-- SUBQUERIES
-- =========================================================

-- Serviços acima da média

SELECT
    id_scs,
    descricao,
    valor
FROM servicos
WHERE valor > (
    SELECT AVG(valor)
    FROM servicos
)
ORDER BY valor DESC;


-- Clientes que possuem pelo menos uma ordem

SELECT
    c.id_c,
    c.nome,
    c.email
FROM clientes c
WHERE c.id_c IN (
    SELECT v.fk_id_cliente
    FROM veiculos v
    INNER JOIN ordens_servico os
        ON os.fk_id_veiculo = v.id_v
)
ORDER BY c.nome;


-- Mecânicos que nunca realizaram uma ordem

SELECT
    m.id_m,
    m.nome AS mecanico,
    e.qual AS especialidade
FROM mecanicos m
LEFT JOIN especialidades e
    ON m.fk_id_especialidade = e.id_eps
WHERE NOT EXISTS (
    SELECT 1
    FROM ordens_servico os
    WHERE os.fk_id_mecanico = m.id_m
)
ORDER BY m.nome;


-- =========================================================
-- TRIGGERS
-- =========================================================

DELIMITER //

--Impedir carros anteriores a 1980
CREATE TRIGGER validar_ano_veiculo BEFORE INSERT ON veiculos FOR EACH ROW
BEGIN
    IF NEW.ano < 1980 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A oficina não atende veículos fabricados antes de 1980.';
    END IF;
END//
DELIMITER ;

DELIMITER //


-- Adiciona o serviço da ordem em servicos_realizados

DROP TRIGGER IF EXISTS adicionar_historico//

CREATE TRIGGER adicionar_historico
AFTER INSERT ON ordens_servico
FOR EACH ROW
BEGIN

    INSERT INTO servicos_realizados (
        fk_id_ordem_servico,
        descricao,
        fk_id_servico,
        valor,
        data_realizacao
    )
    SELECT
        NEW.id_os,
        s.descricao,
        s.id_scs,
        s.valor,
        NEW.data_abertura
    FROM servicos s
    WHERE s.id_scs = NEW.fk_id_servico;

END//


-- Registra alteração de preço

DROP TRIGGER IF EXISTS registrar_alteracao_preco//

CREATE TRIGGER registrar_alteracao_preco
AFTER UPDATE ON servicos
FOR EACH ROW
BEGIN

    IF OLD.valor <> NEW.valor THEN

        INSERT INTO historico_precos (
            fk_id_servico,
            preco_anterior,
            preco_novo,
            data_hora
        )
        VALUES (
            NEW.id_scs,
            OLD.valor,
            NEW.valor,
            NOW()
        );

    END IF;

END//


-- Finaliza automaticamente a ordem

DROP TRIGGER IF EXISTS finalizar_ordem//

CREATE TRIGGER finalizar_ordem
BEFORE UPDATE ON ordens_servico
FOR EACH ROW
BEGIN

    IF NEW.status = 'fechada'
       AND OLD.status <> 'fechada' THEN

        SET NEW.data_fechamento = NOW();

    END IF;

END//

DELIMITER ;


-- =========================================================
-- GROUP BY E HAVING
-- =========================================================

-- Veículos por cliente

SELECT
    c.id_c,
    c.nome AS cliente,
    COUNT(v.id_v) AS total_veiculos
FROM clientes c
INNER JOIN veiculos v
    ON c.id_c = v.fk_id_cliente
GROUP BY
    c.id_c,
    c.nome;


-- Ordens atendidas por mecânico

SELECT
    m.id_m,
    m.nome AS mecanico,
    COUNT(os.id_os) AS total_ordens
FROM mecanicos m
INNER JOIN ordens_servico os
    ON m.id_m = os.fk_id_mecanico
GROUP BY
    m.id_m,
    m.nome
HAVING COUNT(os.id_os) > 0;


-- Mecânicos que participaram de mais de uma ordem

SELECT
    m.id_m,
    m.nome AS mecanico,
    COUNT(os.id_os) AS total_ordens
FROM mecanicos m
INNER JOIN ordens_servico os
    ON m.id_m = os.fk_id_mecanico
GROUP BY
    m.id_m,
    m.nome
HAVING COUNT(os.id_os) > 1;


-- =========================================================
-- CONSULTAS DE FILTRO
-- =========================================================

-- Clientes específicos

SELECT *
FROM clientes
WHERE id_c IN (1, 2, 3);


-- Veículos de um cliente a partir de 2020

SELECT *
FROM veiculos
WHERE fk_id_cliente = 1
  AND ano >= 2020
ORDER BY modelo;


-- Serviços acima de 500

SELECT *
FROM servicos
WHERE valor > 500;


-- Serviços entre 100 e 500

SELECT *
FROM servicos
WHERE valor BETWEEN 100 AND 500;


-- Clientes cujo nome começa com A

SELECT *
FROM clientes
WHERE nome LIKE 'A%';


-- Ordens abertas

SELECT *
FROM ordens_servico
WHERE status = 'aberta';


-- Cinco serviços mais caros

SELECT *
FROM servicos
ORDER BY valor DESC
LIMIT 5;


-- =========================================================
-- TESTES DAS PROCEDURES
-- =========================================================

-- Cadastrar cliente
CALL cadastrar_cliente(
    'Marcos Vinicius Pereira',
    'marcos.pereira@email.com',
    'Rua das Flores, 100'
);


-- Tentativa de cadastrar email duplicado
CALL cadastrar_cliente(
    'Marcos Repetido',
    'marcos.pereira@email.com',
    'Rua A, 100'
);


-- Total de clientes
CALL total_clientes();


-- Total de veículos
CALL total_veiculos();


-- Métricas dos serviços
CALL metricas_servicos();


-- Relatório de cliente
CALL relatorio_cliente(1);


-- Abrir uma ordem
CALL abrir_ordem(
    1,
    1,
    1,
    NOW()
);


-- Recuperar o ID da última ordem criada
SET @id_ordem = LAST_INSERT_ID();


-- Alterar status
CALL alterar_status_ordem(
    @id_ordem,
    'em andamento'
);


-- Finalizar ordem
CALL alterar_status_ordem(
    @id_ordem,
    'fechada'
);


-- Consultar ordem criada
SELECT *
FROM ordens_servico
WHERE id_os = @id_ordem;


-- Consultar serviços realizados
SELECT *
FROM servicos_realizados
WHERE fk_id_ordem_servico = @id_ordem;


-- Consultar histórico de preços
SELECT *
FROM historico_precos
ORDER BY id_hp;

