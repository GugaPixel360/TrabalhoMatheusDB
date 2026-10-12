
CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;
 

 
CREATE TABLE IF NOT EXISTS clientes (
  id_c INT AUTO_INCREMENT PRIMARY KEY,
  cpf CHAR(11) NOT NULL UNIQUE,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  endereco VARCHAR(255)
);
 
CREATE TABLE IF NOT EXISTS veiculos (
  id_v INT AUTO_INCREMENT PRIMARY KEY,
  fk_id_cliente INT NOT NULL,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  ano SMALLINT UNSIGNED NOT NULL,
  placa VARCHAR(8) NOT NULL UNIQUE,
  CONSTRAINT chk_veiculo_ano CHECK (ano BETWEEN 1980 AND 2100),
  CONSTRAINT fk_veiculo_cliente FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_c) ON DELETE CASCADE
);
 
CREATE TABLE IF NOT EXISTS especialidades (
  id_eps INT AUTO_INCREMENT PRIMARY KEY,
  qual VARCHAR(100) NOT NULL UNIQUE
);
 
CREATE TABLE IF NOT EXISTS mecanicos (
  id_m INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  fk_id_especialidade INT NOT NULL,
  CONSTRAINT fk_mecanico_especialidade FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id_eps)
);
 
CREATE TABLE IF NOT EXISTS servicos (
  id_scs INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(255) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  fk_id_especialidade INT NOT NULL,
  CONSTRAINT chk_servico_valor CHECK (valor > 0),
  CONSTRAINT fk_servico_especialidade FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id_eps)
);
 
CREATE TABLE IF NOT EXISTS ordens_servico (
  id_os INT AUTO_INCREMENT PRIMARY KEY,
  fk_id_veiculo INT NOT NULL,
  fk_id_mecanico INT NOT NULL,
  data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_fechamento DATETIME NULL,
  status ENUM('aberta','em andamento','fechada') NOT NULL DEFAULT 'aberta',
  CONSTRAINT fk_os_veiculo FOREIGN KEY (fk_id_veiculo) REFERENCES veiculos(id_v),
  CONSTRAINT fk_os_mecanico FOREIGN KEY (fk_id_mecanico) REFERENCES mecanicos(id_m)
);
 
CREATE TABLE IF NOT EXISTS servicos_realizados (
  id_sr INT AUTO_INCREMENT PRIMARY KEY,
  fk_id_ordem_servico INT NOT NULL,
  descricao VARCHAR(255) NOT NULL,
  fk_id_servico INT NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  data_realizacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_servico_realizado_valor CHECK (valor > 0),
  CONSTRAINT fk_sr_ordem FOREIGN KEY (fk_id_ordem_servico) REFERENCES ordens_servico(id_os) ON DELETE CASCADE,
  CONSTRAINT fk_sr_servico FOREIGN KEY (fk_id_servico) REFERENCES servicos(id_scs)
);
 
CREATE TABLE IF NOT EXISTS historico_precos (
  id_hp INT AUTO_INCREMENT PRIMARY KEY,
  fk_id_servico INT NOT NULL,
  preco_anterior DECIMAL(10,2) NOT NULL,
  preco_novo DECIMAL(10,2) NOT NULL,
  data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_historico_servico FOREIGN KEY (fk_id_servico) REFERENCES servicos(id_scs)
);

-- ============
-- PROCEDURES =
 -- ===========
DELIMITER $$
 
DROP PROCEDURE IF EXISTS cadastrar_cliente$$
CREATE PROCEDURE cadastrar_cliente(
    IN p_nome VARCHAR(100), 
    IN p_email VARCHAR(100), 
    IN p_cpf CHAR(11), 
    IN p_endereco VARCHAR(255)
)
BEGIN
  IF p_nome IS NULL OR TRIM(p_nome) = '' OR p_cpf IS NULL OR p_cpf NOT REGEXP '^[0-9]{11}$' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nome e CPF válido (11 dígitos) são obrigatórios.';
  END IF;
  IF EXISTS (SELECT 1 FROM clientes WHERE email = p_email OR cpf = p_cpf) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email ou CPF já cadastrado.';
  END IF;
  INSERT INTO clientes(nome, email, cpf, endereco) VALUES (p_nome, p_email, p_cpf, p_endereco);
END$$
 
DROP PROCEDURE IF EXISTS abrir_ordem$$
CREATE PROCEDURE abrir_ordem(
    IN p_id_veiculo INT, 
    IN p_id_mecanico INT, 
    IN p_id_servico INT, 
    IN p_data_abertura DATETIME
)
BEGIN
  DECLARE v_id_os INT;
  DECLARE v_descricao VARCHAR(255);
  DECLARE v_valor DECIMAL(10,2);
  IF NOT EXISTS (SELECT 1 FROM veiculos WHERE id_v = p_id_veiculo) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veículo não encontrado.'; 
  END IF;
  IF NOT EXISTS (SELECT 1 FROM mecanicos WHERE id_m = p_id_mecanico) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mecânico não encontrado.'; 
  END IF;
  SELECT descricao, valor INTO v_descricao, v_valor FROM servicos WHERE id_scs = p_id_servico;
  IF v_descricao IS NULL THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Serviço não encontrado.'; 
  END IF;
  INSERT INTO ordens_servico(fk_id_veiculo, fk_id_mecanico, data_abertura) 
  VALUES (p_id_veiculo, p_id_mecanico, COALESCE(p_data_abertura, NOW()));
  SET v_id_os = LAST_INSERT_ID();
  INSERT INTO servicos_realizados(fk_id_ordem_servico, descricao, fk_id_servico, valor, data_realizacao) 
  VALUES (v_id_os, v_descricao, p_id_servico, v_valor, COALESCE(p_data_abertura, NOW()));
END$$
 
DROP PROCEDURE IF EXISTS alterar_status_ordem$$
CREATE PROCEDURE alterar_status_ordem(IN p_id_ordem INT, IN p_novo_status VARCHAR(20))
BEGIN
  IF p_novo_status IS NULL OR p_novo_status NOT IN ('aberta','em andamento','fechada') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Status inválido.'; 
  END IF;
  IF NOT EXISTS (SELECT 1 FROM ordens_servico WHERE id_os = p_id_ordem) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ordem de serviço não encontrada.'; 
  END IF;
 
  UPDATE ordens_servico 
  SET status = p_novo_status 
  WHERE id_os = p_id_ordem;
END$$
 
DROP PROCEDURE IF EXISTS relatorio_cliente$$
CREATE PROCEDURE relatorio_cliente(IN p_id_cliente INT)
BEGIN
  SELECT c.id_c, c.nome, COUNT(DISTINCT os.id_os) AS quantidade_ordens, 
         COUNT(sr.id_sr) AS quantidade_servicos, COALESCE(SUM(sr.valor), 0) AS total_gasto
  FROM clientes c 
  LEFT JOIN veiculos v ON c.id_c = v.fk_id_cliente
  LEFT JOIN ordens_servico os ON v.id_v = os.fk_id_veiculo
  LEFT JOIN servicos_realizados sr ON os.id_os = sr.fk_id_ordem_servico
  WHERE c.id_c = p_id_cliente 
  GROUP BY c.id_c, c.nome;
END$$
 
-- =====================================================================
--  TRIGGERS 
-- =====================================================================
 
-- Auditoria de alterações de preços em serviços
DROP TRIGGER IF EXISTS registrar_alteracao_preco$$
CREATE TRIGGER registrar_alteracao_preco 
AFTER UPDATE ON servicos 
FOR EACH ROW
BEGIN 
  IF OLD.valor <> NEW.valor THEN 
    INSERT INTO historico_precos(fk_id_servico, preco_anterior, preco_novo) 
    VALUES (NEW.id_scs, OLD.valor, NEW.valor); 
  END IF; 
END$$
 
--  Atribuição automática de data de fechamento ao mudar status pra 'fechada'
DROP TRIGGER IF EXISTS finalizar_ordem$$
CREATE TRIGGER finalizar_ordem 
BEFORE UPDATE ON ordens_servico 
FOR EACH ROW
BEGIN
  IF NEW.status = 'fechada' AND OLD.status <> 'fechada' THEN 
    SET NEW.data_fechamento = COALESCE(NEW.data_fechamento, NOW());
  ELSEIF NEW.status <> 'fechada' THEN 
    SET NEW.data_fechamento = NULL;
  END IF;
END$$
 
--  Validação de ano de fabricação do carro
DROP TRIGGER IF EXISTS validar_ano_veiculo_trigger$$
CREATE TRIGGER validar_ano_veiculo_trigger
BEFORE INSERT ON veiculos 
FOR EACH ROW
BEGIN 
  IF NEW.ano < 1980 OR NEW.ano > YEAR(CURDATE()) + 1 THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ano do veículo inválido.'; 
  END IF; 
END$$
 
DELIMITER ;
 
-- =========
-- INSERTS =
 -- ========
 
INSERT INTO clientes(nome, email, cpf, endereco) VALUES
('Ana Silva', 'ana@email.com', '11111111111', 'Rua A, 100'),
('Bruno Dias', 'bruno@email.com', '22222222222', 'Rua B, 200'),
('Carlos Souza', 'carlos@email.com', '33333333333', 'Rua C, 300'),
('Diana Costa', 'diana@email.com', '44444444444', 'Rua D, 400'),
('Eduardo Lima', 'eduardo@email.com', '55555555555', 'Rua E, 500'),
('Fernanda Rocha', 'fernanda@email.com', '66666666666', 'Rua F, 600'),
('Gabriel Mendes', 'gabriel@email.com', '77777777777', 'Rua G, 700'),
('Helena Martins', 'helena@email.com', '88888888888', 'Rua H, 800'),
('Igor Santos', 'igor@email.com', '99999999999', 'Rua I, 900'),
('Juliana Ribeiro', 'juliana@email.com', '10101010101', 'Rua J, 1000');
 
INSERT INTO especialidades(qual) VALUES 
('Mecânica Geral'), ('Elétrica'), ('Injeção Eletrônica'), ('Suspensão e Freios');
 
INSERT INTO mecanicos(nome, fk_id_especialidade) VALUES 
('João Mecânico', 1), 
('Pedro Elétrico', 2), 
('Lucas Injeção', 3), 
('Marcos Suspensão', 4), 
('Roberto Geral', 1);
 
INSERT INTO servicos(descricao, valor, fk_id_especialidade) VALUES 
('Troca de Óleo', 150.00, 1),
('Troca de Bateria', 400.00, 2),
('Limpeza de Bicos', 250.00, 3),
('Troca de Pastilhas', 200.00, 4),
('Alinhamento e Balanceamento', 120.00, 4),
('Revisão do Sistema de Ignição', 350.00, 2),
('Troca de Correia Dentada', 600.00, 1),
('Reparo no Alternador', 480.00, 2),
('Diagnóstico Eletrônico', 180.00, 3),
('Troca de Amortecedores', 900.00, 4);
 
INSERT INTO veiculos(fk_id_cliente, marca, modelo, ano, placa) VALUES 
(1, 'Fiat', 'Palio', 2010, 'ABC-1234'),
(1, 'Fiat', 'Siena', 2012, 'ABC-1235'),
(2, 'VW', 'Gol', 2015, 'GHI-9012'),
(3, 'Ford', 'Ka', 2018, 'JKL-3456'),
(4, 'Chevrolet', 'Onix', 2020, 'MNO-7890'),
(5, 'Hyundai', 'HB20', 2019, 'PQR-1234'),
(6, 'Toyota', 'Corolla', 2021, 'STU-5678'),
(7, 'Honda', 'Civic', 2017, 'VWX-9012'),
(8, 'Renault', 'Kwid', 2022, 'YZA-3456'),
(9, 'Nissan', 'Versa', 2016, 'BCD-7890'),
(10, 'Jeep', 'Renegade', 2023, 'EFG-1234'),
(10, 'Jeep', 'Compass', 2024, 'HIJ-5678');
 
-- 10 Ordens de Serviço
INSERT INTO ordens_servico(fk_id_veiculo, fk_id_mecanico, data_abertura, status) VALUES 
(1, 1, '2026-01-10 08:00:00', 'fechada'),
(2, 5, '2026-01-15 09:30:00', 'fechada'),
(3, 2, '2026-02-01 10:00:00', 'em andamento'),
(4, 3, '2026-02-10 14:00:00', 'aberta'),
(5, 4, '2026-02-12 11:15:00', 'fechada'),
(6, 1, '2026-03-01 08:30:00', 'em andamento'),
(7, 2, '2026-03-05 13:00:00', 'aberta'),
(8, 3, '2026-03-10 15:20:00', 'fechada'),
(9, 4, '2026-03-12 09:00:00', 'aberta'),
(10, 5, '2026-03-15 16:00:00', 'fechada');
 
-- 15 Itens / Serviços Realizados
INSERT INTO servicos_realizados(fk_id_ordem_servico, descricao, fk_id_servico, valor) VALUES 
(1, 'Troca de Óleo', 1, 150.00),
(1, 'Troca de Correia Dentada', 7, 600.00),
(2, 'Troca de Bateria', 2, 400.00),
(3, 'Diagnóstico Eletrônico', 9, 180.00),
(4, 'Limpeza de Bicos', 3, 250.00),
(5, 'Troca de Pastilhas', 4, 200.00),
(5, 'Alinhamento e Balanceamento', 5, 120.00),
(6, 'Revisão do Sistema de Ignição', 6, 350.00),
(7, 'Reparo no Alternador', 8, 480.00),
(8, 'Troca de Amortecedores', 10, 900.00),
(8, 'Alinhamento e Balanceamento', 5, 120.00),
(9, 'Troca de Óleo', 1, 150.00),
(10, 'Troca de Bateria', 2, 400.00),
(10, 'Diagnóstico Eletrônico', 9, 180.00),
(10, 'Limpeza de Bicos', 3, 250.00);
 

 
-- [CREATE / INSERT] Exemplos adicionais
INSERT INTO clientes(nome, email, cpf, endereco) VALUES ('Kleber Teste', 'kleber@email.com', '00000000001', 'Av Central');
INSERT INTO servicos(descricao, valor, fk_id_especialidade) VALUES ('Geometria 3D', 140.00, 4);
 
-- [READ / SELECT] Exemplos adicionais
SELECT nome, email FROM clientes WHERE endereco LIKE '%Rua%';
SELECT descricao, valor FROM servicos ORDER BY valor ASC;
 
-- [UPDATE] Exemplos adicionais
UPDATE clientes SET endereco = 'Rua Nova, 500' WHERE nome = 'Kleber Teste';
UPDATE servicos SET valor = 160.00 WHERE descricao = 'Troca de Óleo'; -- Aciona a Trigger de histórico de preços
 
-- [DELETE] Exemplos adicionais
DELETE FROM servicos WHERE descricao = 'Geometria 3D';
DELETE FROM clientes WHERE nome = 'Kleber Teste';
 
-- ==========================================================
-- SEÇÃO 6: CONSULTAS, FILTROS, AGREGAÇÃO, JOINS E SUBQUERIES
-- ==========================================================

SELECT * FROM clientes WHERE nome LIKE 'A%';
SELECT * FROM servicos WHERE valor BETWEEN 100.00 AND 500.00;
SELECT * FROM servicos WHERE valor > 500.00 OR fk_id_especialidade = 2;
SELECT * FROM ordens_servico WHERE status = 'aberta' ORDER BY data_abertura ASC LIMIT 5;
 

SELECT 
  (SELECT COUNT(*) FROM clientes) AS total_clientes,
  (SELECT COUNT(*) FROM veiculos) AS total_veiculos,
  MAX(valor) AS servico_mais_caro,
  MIN(valor) AS servico_mais_barato,
  ROUND(AVG(valor), 2) AS preco_medio,
  SUM(valor) AS valor_total_catalogo 
FROM servicos;
 

SELECT c.nome AS cliente, COUNT(v.id_v) AS qtd_veiculos
FROM clientes c
LEFT JOIN veiculos v ON c.id_c = v.fk_id_cliente
GROUP BY c.id_c, c.nome;
 
SELECT m.nome AS mecanico, COUNT(os.id_os) AS qtd_ordens
FROM mecanicos m
JOIN ordens_servico os ON m.id_m = os.fk_id_mecanico
GROUP BY m.id_m, m.nome
HAVING COUNT(os.id_os) > 1;
 

SELECT c.nome AS cliente, v.modelo, v.placa 
FROM clientes c 
LEFT JOIN veiculos v ON c.id_c = v.fk_id_cliente;


SELECT os.id_os, c.nome AS cliente, v.marca, v.modelo, v.placa, 
       m.nome AS mecanico, sr.descricao AS servico, sr.valor, 
       os.data_abertura, os.data_fechamento, os.status 
FROM ordens_servico os 
JOIN veiculos v ON v.id_v = os.fk_id_veiculo 
JOIN clientes c ON c.id_c = v.fk_id_cliente
JOIN mecanicos m ON m.id_m = os.fk_id_mecanico 
LEFT JOIN servicos_realizados sr ON sr.fk_id_ordem_servico = os.id_os 
ORDER BY os.data_abertura DESC, c.nome;


SELECT id_scs, descricao, valor 
FROM servicos 
WHERE valor > (SELECT AVG(valor) FROM servicos) 
ORDER BY valor DESC;

 

SELECT nome, email FROM clientes 
WHERE id_c IN (SELECT fk_id_cliente FROM veiculos GROUP BY fk_id_cliente HAVING COUNT(*) > 1);

 

SELECT nome FROM mecanicos 
WHERE fk_id_especialidade IN (SELECT fk_id_especialidade FROM servicos WHERE valor > 400.00);

 
-- =====================================================================
-- SEÇÃO 7: DESAFIOS FINAIS E RELATÓRIOS
-- =====================================================================
 
-- Desafio 1: Relatório de Gastos por Cliente
SELECT c.nome AS cliente, COUNT(DISTINCT os.id_os) AS quantidade_ordens, 
       COALESCE(SUM(sr.valor), 0) AS total_gasto
FROM clientes c
LEFT JOIN veiculos v ON c.id_c = v.fk_id_cliente
LEFT JOIN ordens_servico os ON v.id_v = os.fk_id_veiculo
LEFT JOIN servicos_realizados sr ON os.id_os = sr.fk_id_ordem_servico
GROUP BY c.id_c, c.nome
ORDER BY total_gasto DESC;
 
-- Desafio 2: Mecânico que gerou o maior valor em serviços
SELECT m.nome AS mecanico, COUNT(DISTINCT os.id_os) AS quantidade_ordens,
       COUNT(sr.id_sr) AS quantidade_servicos, SUM(sr.valor) AS valor_total
FROM mecanicos m
JOIN ordens_servico os ON m.id_m = os.fk_id_mecanico
JOIN servicos_realizados sr ON os.id_os = sr.fk_id_ordem_servico
GROUP BY m.id_m, m.nome
ORDER BY valor_total DESC
LIMIT 1;
 
-- =====================================================================
-- SEÇÃO 8: TESTES
-- =====================================================================
 
/*
-- Teste 1: CPF duplicado (Protegido por UNIQUE)
INSERT INTO clientes(nome, email, cpf, endereco) VALUES ('Teste CPF', 'teste@email.com', '11111111111', 'Rua X');
 
-- Teste 2: Veículo para cliente inexistente (Protegido por FOREIGN KEY)
INSERT INTO veiculos(fk_id_cliente, marca, modelo, ano, placa) VALUES (999, 'Fiat', 'Uno', 2010, 'ZZZ-9999');
 
-- Teste 3  : Preço de serviço inválido/negativo (Protegido por CHECK constraint)
INSERT INTO servicos(descricao, valor, fk_id_especialidade) VALUES ('Serviço Errado', -50.00, 1);
 
-- Teste 4: Exclusão de cliente com veículo associado sem Cascade (Protegido por FK restritiva ou tratado por Cascade)
DELETE FROM clientes WHERE id_c = 1;
*/