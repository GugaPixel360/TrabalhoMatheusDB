-------------------------
-- CRIACAO DA DATABASE --
-------------------------
CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;
    
------------------------
-- CRIACAO DAS TABLES --
------------------------

-- CLIENTES
CREATE TABLE IF NOT EXISTS clientes(           
    id_c INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    endereco VARCHAR(255)
);
    
-- VEICULOS 
CREATE TABLE IF NOT EXISTS veiculos(
    id_v INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_cliente INT NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    placa VARCHAR(8) UNIQUE NOT NULL,
    
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id_c)
);
    
-- ESPECIALIDADES
CREATE TABLE IF NOT EXISTS especialidades(
    id_eps INT AUTO_INCREMENT PRIMARY KEY,
    qual VARCHAR(100) NOT NULL
);
    
-- MECANICOS 
CREATE TABLE IF NOT EXISTS mecanicos(
    id_m INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    fk_id_especialidade INT,
    
    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id_eps)
);
    
-- SERVIÇOS
CREATE TABLE IF NOT EXISTS servicos(
    id_scs INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fk_id_especialidade INT,
    
    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id_eps)
);
    
-- ORDENS DE SERVIÇOS
CREATE TABLE IF NOT EXISTS ordens_servico(
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_veiculo INT NOT NULL,
    fk_id_mecanico INT NOT NULL,
    fk_id_servico INT NOT NULL,
    data_abertura DATETIME NOT NULL,
    data_fechamento DATETIME NULL,
    status ENUM('aberta', 'em andamento', 'fechada') DEFAULT 'aberta',
    
    FOREIGN KEY (fk_id_veiculo) REFERENCES veiculos(id_v),
    FOREIGN KEY (fk_id_mecanico) REFERENCES mecanicos(id_m),
    FOREIGN KEY (fk_id_servico) REFERENCES servicos(id_scs)
);
    
-- HISTORICO
CREATE TABLE IF NOT EXISTS servicos_realizados(
    id_sr INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_ordem_servico INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    fk_valor INT NOT NULL,
    data_realizacao DATETIME NOT NULL,
    
    FOREIGN KEY (fk_id_ordem_servico) REFERENCES ordens_servico (id_os),
    FOREIGN KEY (fk_valor) REFERENCES servicos   
);


DELIMITER $$

CREATE PROCEDURE cadastrar_cliente(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_endereco VARCHAR(255)
)
BEGIN
    IF EXISTS (SELECT 1 FROM clientes WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email já cadastrado.';
    ELSE
        INSERT INTO clientes (nome, email, endereco)
        VALUES (p_nome, p_email, p_endereco);
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE abrir_ordem(
    IN p_id_veiculo INT,
    IN p_id_mecanico INT,
    IN p_id_servico INT
    IN p_data_abertura DATETIME
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM veiculos WHERE id_v = p_id_veiculo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veículo não encontrado.';

    ELSE IF NOT EXISTS (SELECT 1 FROM mecanicos WHERE id_m = p_id_mecanico) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Mecânico não encontrado.';

    ELSE IF NOT EXISTS (SELECT 1 FROM servicos WHERE id_scs = p_id_servico) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Serviço não encontrado.';

    ELSE
        INSERT INTO ordens_servico (fk_id_veiculo, fk_id_mecanico, fk_id_servico, data_abertura)
        VALUES (p_id_veiculo, p_id_mecanico, p_id_servico, p_data_abertura);
    
    END IF$$
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE alterar_status_ordem(
    IN p_id_ordem INT,
    IN p_novo_status ENUM('aberta', 'em andamento', 'fechada')
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ordens_servico WHERE id_os = p_id_ordem) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ordem de serviço não encontrada.';
    
    ELSE
        UPDATE ordens_servico
        SET status = p_novo_status, data_fechamento = null
        WHERE id_os = p_id_ordem;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE relatorio_cliente(
    IN p_id_cliente INT
)
BEGIN
    SELECT c.id_c, c.nome, COUNT(os.fk_id_cliente) AS quantidade_servicos, SUM(s.valor) AS total_gasto
    FROM clientes c
    JOIN ordens_servico os ON c.id_c = os.fk_id_cliente
    JOIN servicos s ON os.fk_id_servico = s.id_scs
    WHERE c.id_c = p_id_cliente
    GROUP BY c.id_c, c.nome;
END$$

DELIMITER ;

--------------------------
-- CRIACAO DAS TRIGGERS --
--------------------------

-- trigger add ao historico 
DELIMITER //

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

DELIMITER ;
