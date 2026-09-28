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
    
    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id)
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
    
    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id)
);
    
-- SERVIÇOS
CREATE TABLE IF NOT EXISTS servicos(
    id_scs INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fk_id_especialidade INT,
    
    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id)
);
    
-- ORDENS DE SERVIÇOS
CREATE TABLE IF NOT EXISTS ordens_servico(
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_veiculo INT NOT NULL,
    fk_id_mecanico INT NOT NULL,
    fk_id_servico INT NOT NULL,
    data_abertura DATETIME NOT NULL,
    data_fechamento DATETIME,
    status ENUM('aberta', 'em andamento', 'fechada') 
    DEFAULT 'aberta',
    
    FOREIGN KEY (fk_id_veiculo) REFERENCES veiculos(id),
    FOREIGN KEY (fk_id_mecanico) REFERENCES mecanicos(id),
    FOREIGN KEY (fk_id_servico) REFERENCES servicos(id)
);
    
-- HISTORICO
CREATE TABLE IF NOT EXISTS servicos_realizados(
    id_sr INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_ordem_servico INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    fk_valor INT NOT NULL,
    data_realizacao DATETIME NOT NULL,
    
    FOREIGN KEY (fk_id_ordem_servico) REFERENCES ordens_servico (id),
    FOREIGN KEY (fk_valor) REFERENCES servicos   
);


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

