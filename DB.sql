CREATE DATABASE IF NOT EXISTS oficina_mecanica;
USE oficina_mecanica;
CREATE TABLE IF NOT EXISTS clientes(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    endereco VARCHAR(255)
);
CREATE TABLE IF NOT EXISTS veiculos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_cliente INT NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    ano INT NOT NULL,
    placa VARCHAR(8) UNIQUE NOT NULL,

    FOREIGN KEY (fk_id_cliente) REFERENCES clientes(id)
);
CREATE TABLE IF NOT EXISTS especialidades(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);
CREATE TABLE IF NOT EXISTS mecanicos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    fk_id_especialidade INT,

    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id)
);
CREATE TABLE IF NOT EXISTS servicos(
    id INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    fk_id_especialidade INT,

    FOREIGN KEY (fk_id_especialidade) REFERENCES especialidades(id)
);
CREATE TABLE IF NOT EXISTS ordens_servico(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_veiculo INT NOT NULL,
    fk_id_mecanico INT NOT NULL,
    fk_id_servico INT NOT NULL,
    data_abertura DATETIME NOT NULL,
    data_fechamento DATETIME,
    status ENUM('aberta', 'em andamento', 'fechada') DEFAULT 'aberta',

    FOREIGN KEY (fk_id_veiculo) REFERENCES veiculos(id),
    FOREIGN KEY (fk_id_mecanico) REFERENCES mecanicos(id),
    FOREIGN KEY (fk_id_servico) REFERENCES servicos(id)
);
CREATE TABLE IF NOT EXISTS servicos_realizados(
    id INT AUTO_INCREMENT PRIMARY KEY,
    fk_id_ordem_servico INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    fk_valor DECIMAL(10, 2) NOT NULL,
    data_realizacao DATETIME NOT NULL,

    FOREIGN KEY (fk_id_ordem_servico) REFERENCES ordens_servico (id)
)