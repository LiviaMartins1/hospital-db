# 🏥 `hospital_db` — Banco de Dados Relacional Hospitalar

Modelagem, implementação e análise de dados em **MySQL 8.0** para o gerenciamento operacional e financeiro de uma unidade hospitalar. O projeto centraliza o fluxo de atendimento desde o cadastro de pacientes e profissionais até o controle de leitos, internações, consultas e prescrições médicas[cite: 1, 2, 3, 4, 5, 6].

---

## 📋 Visão Geral

Sistemas hospitalares exigem integridade estrita entre registros clínicos e administrativos. Este projeto substitui controles isolados por um esquema relacional normalizado (`InnoDB`, `utf8mb4`), assegurando rastreabilidade entre:

* **Atendimento Ambulatorial:** Agendamento, status e faturamento de consultas por especialidade e convênio[cite: 1, 3, 4].
* **Gestão de Leitos e Internações:** Controle de ocupação por andar/categoria (`UTI`, `Apartamento`, `Enfermaria`, `Suíte VIP`) e cálculo de diárias[cite: 2, 6].
* **Prescrição Médica:** Histórico de medicamentos, posologia e quantidades vinculadas a cada atendimento[cite: 5].

---

## 📂 Organização do Repositório

```text
📦 hospital_db
 ┣ 📜 hospital_db_pacientes.sql     # DDL e carga inicial de pacientes
 ┣ 📜 hospital_db_medicos.sql       # DDL e carga inicial do corpo clínico
 ┣ 📜 hospital_db_quartos.sql       # DDL e carga inicial da estrutura de leitos
 ┣ 📜 hospital_db_internacoes.sql   # DDL e carga inicial de internações
 ┣ 📜 hospital_db_consultas.sql     # DDL e carga inicial de consultas
 ┣ 📜 hospital_db_prescricoes.sql   # DDL e carga inicial de prescrições
 ┣ 📜 consultas.sql                 # Queries analíticas e relatórios gerenciais
 ┗ 🖼️ der.png                       # Diagrama Entidade-Relacionamento
```

---

## 🗺️ Arquitetura e Modelagem

O banco é composto por **6 entidades** interligadas por chaves estrangeiras (`FK`) com cardinalidade **1:N** (um para muitos)[cite: 1, 2, 3, 4, 5, 6, 32]:

* `pacientes` **(1) ──< (N)** `consultas` e `internacoes`[cite: 1, 2, 4, 32]
* `medicos` **(1) ──< (N)** `consultas`[cite: 1, 3, 32]
* `quartos` **(1) ──< (N)** `internacoes`[cite: 2, 6, 32]
* `consultas` **(1) ──< (N)** `prescricoes`[cite: 1, 5, 32]

### Diagrama Entidade-Relacionamento (DER)

<img width="1024" height="761" alt="image" src="https://github.com/user-attachments/assets/fde4b668-23ee-41a0-bcdb-bf8f7ab09615" />


---

## 🧱 Dicionário de Dados e Estrutura DDL

<details>
<summary><strong>1. Tabela <code>pacientes</code></strong> — Cadastro de pacientes e convênios</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_paciente` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do paciente |
| `nome_paciente` | `VARCHAR(100)` | `NOT NULL`, `INDEX` | Nome completo |
| `cpf` | `CHAR(14)` | `NOT NULL`, `UNIQUE` | CPF formatado (`000.000.000-00`) |
| `data_nascimento` | `DATE` | `NOT NULL` | Data de nascimento |
| `telefone_paciente` | `CHAR(15)` | `NULL` | Telefone de contato |
| `convenio` | `CHAR(50)` | `NOT NULL` | Plano de saúde ou `Particular` |

```sql
CREATE TABLE pacientes (
  id_paciente INT NOT NULL AUTO_INCREMENT,
  nome_paciente VARCHAR(100) NOT NULL,
  cpf CHAR(14) NOT NULL,
  data_nascimento DATE NOT NULL,
  telefone_paciente CHAR(15) DEFAULT NULL,
  convenio CHAR(50) NOT NULL,
  PRIMARY KEY (id_paciente),
  UNIQUE KEY cpf (cpf),
  KEY idx_pacientes_nome (nome_paciente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

<details>
<summary><strong>2. Tabela <code>medicos</code></strong> — Corpo clínico e especialidades</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_medico` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do médico |
| `nome_medico` | `CHAR(100)` | `NOT NULL` | Nome do profissional |
| `crm` | `CHAR(12)` | `NOT NULL`, `UNIQUE` | Registro no Conselho Regional de Medicina |
| `especialidade` | `CHAR(50)` | `NOT NULL`, `INDEX` | Área de atuação médica |

```sql
CREATE TABLE medicos (
  id_medico INT NOT NULL AUTO_INCREMENT,
  nome_medico CHAR(100) NOT NULL,
  crm CHAR(12) NOT NULL,
  especialidade CHAR(50) NOT NULL,
  PRIMARY KEY (id_medico),
  UNIQUE KEY crm (crm),
  KEY idx_medicos_especialidade (especialidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

<details>
<summary><strong>3. Tabela <code>quartos</code></strong> — Mapeamento de leitos hospitalares</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_quarto` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único do quarto |
| `numero_quarto` | `CHAR(3)` | `NOT NULL`, `UNIQUE` | Numeração física do leito |
| `andar` | `CHAR(3)` | `NOT NULL` | Pavimento onde se localiza |
| `tipo_quarto` | `CHAR(30)` | `NOT NULL` | `UTI`, `Enfermaria`, `Apartamento` ou `Suíte VIP` |
| `status_quarto` | `CHAR(20)` | `NOT NULL`, `DEFAULT 'Livre'` | Disponibilidade atual (`Livre` / `Ocupado`) |

```sql
CREATE TABLE quartos (
  id_quarto INT NOT NULL AUTO_INCREMENT,
  numero_quarto CHAR(3) NOT NULL,
  andar CHAR(3) NOT NULL,
  tipo_quarto CHAR(30) NOT NULL,
  status_quarto CHAR(20) NOT NULL DEFAULT 'Livre',
  PRIMARY KEY (id_quarto),
  UNIQUE KEY numero_quarto (numero_quarto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

<details>
<summary><strong>4. Tabela <code>internacoes</code></strong> — Histórico de ocupação e diárias</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_internacao` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único da internação |
| `id_paciente` | `INT` | `FK` (`pacientes`) | Paciente internado |
| `id_quarto` | `INT` | `FK` (`quartos`) | Quarto ocupado |
| `data_entrada` | `DATE` | `NOT NULL` | Data de admissão |
| `data_saida` | `DATE` | `NULL` | Data de alta hospitalar |
| `valor_diaria` | `DECIMAL(10,2)` | `NOT NULL` | Valor cobrado por dia |

```sql
CREATE TABLE internacoes (
  id_internacao INT NOT NULL AUTO_INCREMENT,
  id_paciente INT NOT NULL,
  id_quarto INT NOT NULL,
  data_entrada DATE NOT NULL,
  data_saida DATE DEFAULT NULL,
  valor_diaria DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_internacao),
  FOREIGN KEY (id_quarto) REFERENCES quartos (id_quarto),
  FOREIGN KEY (id_paciente) REFERENCES pacientes (id_paciente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

<details>
<summary><strong>5. Tabela <code>consultas</code></strong> — Registro de atendimentos ambulatoriais</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_consulta` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único da consulta |
| `data_consulta` | `DATETIME` | `NOT NULL`, `INDEX` | Data e hora agendada |
| `status_consulta` | `CHAR(20)` | `NULL` | Situação do atendimento (ex.: `Realizada`) |
| `valor_consulta` | `DECIMAL(10,2)` | `NULL` | Valor cobrado pelo atendimento |
| `id_paciente` | `INT` | `FK` (`pacientes`) | Paciente atendido |
| `id_medico` | `INT` | `FK` (`medicos`) | Médico responsável |

```sql
CREATE TABLE consultas (
  id_consulta INT NOT NULL AUTO_INCREMENT,
  data_consulta DATETIME NOT NULL,
  status_consulta CHAR(20) DEFAULT NULL,
  valor_consulta DECIMAL(10,2) DEFAULT NULL,
  id_paciente INT NOT NULL,
  id_medico INT NOT NULL,
  PRIMARY KEY (id_consulta),
  KEY idx_consultas_data (data_consulta),
  FOREIGN KEY (id_paciente) REFERENCES pacientes (id_paciente),
  FOREIGN KEY (id_medico) REFERENCES medicos (id_medico)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

<details>
<summary><strong>6. Tabela <code>prescricoes</code></strong> — Medicamentos receitados</summary>

| Coluna | Tipo | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_prescricao` | `INT` | `PK`, `AUTO_INCREMENT` | Identificador único da prescrição |
| `id_consulta` | `INT` | `FK` (`consultas`) | Consulta que originou a receita |
| `medicamento` | `CHAR(100)` | `NOT NULL` | Fármaco e concentração |
| `dosagem` | `CHAR(50)` | `NOT NULL` | Frequência e via de administração |
| `quantidade` | `CHAR(30)` | `NOT NULL` | Unidades prescritas |

```sql
CREATE TABLE prescricoes (
  id_prescricao INT NOT NULL AUTO_INCREMENT,
  id_consulta INT NOT NULL,
  medicamento CHAR(100) NOT NULL,
  dosagem CHAR(50) NOT NULL,
  quantidade CHAR(30) NOT NULL,
  PRIMARY KEY (id_prescricao),
  FOREIGN KEY (id_consulta) REFERENCES consultas (id_consulta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
</details>

---

## ⚡ Performance e Indexação

Além dos índices automáticos gerados por `PRIMARY KEY`, `FOREIGN KEY` e `UNIQUE`, o esquema define índices secundários para acelerar filtros recorrentes[cite: 1, 3, 4]:

* `idx_pacientes_nome` em `pacientes(nome_paciente)` — agiliza buscas cadastrais por nome[cite: 4].
* `idx_medicos_especialidade` em `medicos(especialidade)` — otimiza triagens e relatórios por área médica[cite: 3].
* `idx_consultas_data` em `consultas(data_consulta)` — melhora consultas de agenda e faturamento por período[cite: 1].

---

## 🛠️ Instalação e Execução

### Pré-requisitos
* **MySQL Server 8.0+**
* Cliente SQL (**MySQL Workbench**, **DBeaver** ou CLI `mysql`)

### Passo a Passo

1. **Crie e selecione o banco de dados:**
   ```sql
   CREATE DATABASE IF NOT EXISTS hospital_db
   CHARACTER SET utf8mb4
   COLLATE utf8mb4_0900_ai_ci;

   USE hospital_db;
   ```

2. **Importe os dumps respeitando a hierarquia das chaves estrangeiras:**
   ```bash
   mysql -u root -p hospital_db < hospital_db_pacientes.sql
   mysql -u root -p hospital_db < hospital_db_medicos.sql
   mysql -u root -p hospital_db < hospital_db_quartos.sql
   mysql -u root -p hospital_db < hospital_db_internacoes.sql
   mysql -u root -p hospital_db < hospital_db_consultas.sql
   mysql -u root -p hospital_db < hospital_db_prescricoes.sql
   ```
   > **Nota:** Caso utilize o **MySQL Workbench**, abra cada script via `File > Open SQL Script` na ordem listada acima e execute. Todos os arquivos contêm `DROP TABLE IF EXISTS`, recriando as tabelas do zero[cite: 1, 2, 3, 4, 5, 6].

3. **Valide a carga de dados:**
   ```sql
   SHOW TABLES;
   ```

---

## 📈 Consultas Analíticas (`consultas.sql`)

O arquivo `consultas.sql` reúne relatórios gerenciais construídos com `INNER JOIN`, agregações (`SUM`, `AVG`, `COUNT`), filtros (`WHERE`, `LIKE`) e ordenação[cite: 7]:

| # | Indicador | Objetivo de Negócio | Recursos SQL |
| :-: | :--- | :--- | :--- |
| **01** | **Receita por Convênio** | Total faturado em consultas de convênios com `"Saúde"` no nome | `INNER JOIN`, `SUM`, `LIKE`, `GROUP BY` |
| **02** | **Ticket Médio (Cardiologia)** | Valor médio das consultas nas especialidades cardiológicas | `INNER JOIN`, `AVG`, `LIKE`, `GROUP BY` |
| **03** | **Diária Média por Acomodação** | Comparativo de diárias entre `Apartamento` e `UTI` | `INNER JOIN`, `AVG`, `OR`, `GROUP BY` |
| **04** | **Ranking de Produção Médica** | Faturamento total por médico em consultas `Realizada` ou `Finalizada` | `INNER JOIN`, `SUM`, `ORDER BY DESC` |
| **05** | **Custo de Internação (Família Silva)** | Soma das diárias de internação para pacientes com sobrenome `"Silva"` | `INNER JOIN`, `SUM`, `LIKE`, `GROUP BY` |
| **06** | **Demanda de Analgésicos** | Contagem de prescrições de `Dipirona` e `Paracetamol` por status | `INNER JOIN`, `COUNT`, `LIKE`, `GROUP BY` |
| **07** | **Média de UTI por Operadora** | Custo médio de diária em `UTI` segmentado por convênio | `3x JOIN`, `AVG`, `GROUP BY` |
| **08** | **Volume de Receitas por Médico** | Total de medicamentos prescritos por profissional em consultas realizadas | `3x JOIN`, `COUNT`, `GROUP BY` |
| **09** | **Gasto por Paciente (Inicial "M")** | Total acumulado e média por consulta para pacientes iniciados em `"M"` | `INNER JOIN`, `SUM`, `AVG`, `LIKE` |

### Exemplos de Queries

<details>
<summary><strong>Ver código completo das consultas (<code>consultas.sql</code>)</strong></summary>

```sql
USE hospital_db;

-- 1. Faturamento total das consultas por convênio ("Saúde")
SELECT 
    pacientes.convenio,
    SUM(consultas.valor_consulta) AS valor_total
FROM pacientes
INNER JOIN consultas ON pacientes.id_paciente = consultas.id_paciente
WHERE pacientes.convenio LIKE '%Saúde%'
GROUP BY pacientes.convenio;

-- 2. Média das consultas de Cardiologia
SELECT 
    medicos.especialidade, 
    AVG(consultas.valor_consulta) AS media_consulta 
FROM medicos
INNER JOIN consultas ON medicos.id_medico = consultas.id_medico
WHERE medicos.especialidade LIKE '%Cardiologia%'
GROUP BY medicos.especialidade;

-- 3. Média das diárias por tipo de quarto (Apartamento e UTI)
SELECT 
    quartos.tipo_quarto,
    AVG(internacoes.valor_diaria) AS media_diaria
FROM quartos 
INNER JOIN internacoes ON quartos.id_quarto = internacoes.id_quarto
WHERE quartos.tipo_quarto = 'Apartamento'
   OR quartos.tipo_quarto = 'UTI'
GROUP BY quartos.tipo_quarto;

-- 4. Total recebido por cada médico
SELECT
    medicos.nome_medico,
    SUM(consultas.valor_consulta) AS total_consultas
FROM medicos 
INNER JOIN consultas ON medicos.id_medico = consultas.id_medico
WHERE consultas.status_consulta = 'Realizada'
   OR consultas.status_consulta = 'Finalizada'
GROUP BY medicos.id_medico, medicos.nome_medico
ORDER BY total_consultas DESC;

-- 5. Soma das diárias dos pacientes com sobrenome Silva
SELECT
    pacientes.nome_paciente,
    SUM(internacoes.valor_diaria) AS total_diarias
FROM pacientes
INNER JOIN internacoes ON pacientes.id_paciente = internacoes.id_paciente
WHERE pacientes.nome_paciente LIKE '%Silva%'
GROUP BY pacientes.id_paciente, pacientes.nome_paciente;

-- 6. Contagem de prescrições de Dipirona e Paracetamol
SELECT 
    consultas.status_consulta, 
    COUNT(prescricoes.id_prescricao) AS quantidade
FROM consultas
INNER JOIN prescricoes ON consultas.id_consulta = prescricoes.id_consulta
WHERE prescricoes.medicamento LIKE '%Dipirona%'
   OR prescricoes.medicamento LIKE '%Paracetamol%'
GROUP BY consultas.status_consulta;

-- 7. Média das diárias em quartos UTI por convênio
SELECT 
    pacientes.convenio,
    AVG(internacoes.valor_diaria) AS media
FROM pacientes
INNER JOIN internacoes ON internacoes.id_paciente = pacientes.id_paciente
INNER JOIN quartos ON internacoes.id_quarto = quartos.id_quarto
WHERE quartos.tipo_quarto = 'UTI'
GROUP BY pacientes.convenio;

-- 8. Quantidade de medicamentos prescritos por médico
SELECT
    medicos.nome_medico,
    COUNT(prescricoes.id_prescricao) AS quantidade
FROM medicos
INNER JOIN consultas ON medicos.id_medico = consultas.id_medico 
INNER JOIN prescricoes ON consultas.id_consulta = prescricoes.id_consulta
WHERE consultas.status_consulta = 'Realizada'
GROUP BY medicos.nome_medico;

-- 9. Total e média de consultas para pacientes com inicial "M"
SELECT 
    pacientes.nome_paciente,
    SUM(consultas.valor_consulta) AS total,
    AVG(consultas.valor_consulta) AS media
FROM pacientes
INNER JOIN consultas ON pacientes.id_paciente = consultas.id_paciente
WHERE pacientes.nome_paciente LIKE 'M%'
GROUP BY pacientes.nome_paciente;
```
</details>
