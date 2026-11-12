USE hospital_db;


-- 1 Calcular o faturamento total das consultas por convenio.

SELECT 
    pacientes.convenio,
    SUM(consultas.valor_consulta) AS valor_total
FROM pacientes
INNER JOIN consultas ON pacientes.id_paciente = consultas.id_paciente
WHERE pacientes.convenio LIKE '%Saúde%'
GROUP BY pacientes.convenio;

-- 2 alcular a media das consultas de cardiologia.

select 
medicos.especialidade, 
avg(consultas.valor_consulta) as media_consulta 
from medicos
inner join consultas
on medicos.id_medico = consultas.id_medico
where medicos.especialidade like '%Cardiologia%'
group by medicos.especialidade;

-- 3 Mostrar a media das diarias por tipo de quarto.

select 
quartos.tipo_quarto,
avg(internacoes.valor_diaria) as media_diara
from quartos 
inner join internacoes 
on quartos.id_quarto = internacoes.id_quarto
where  quartos.tipo_quarto = 'Apartamento'
or  quartos.tipo_quarto = 'UTI'
group by quartos.tipo_quarto;

-- 4 Mostrar o total recebido por cada medico.

select
medicos.nome_medico,
sum(consultas.valor_consulta) as total_consultas
from medicos 
inner join consultas
on medicos.id_medico = consultas.id_medico
where consultas.status_consulta = 'Realizada'
or consultas.status_consulta = ('Finalizada')
group by medicos.id_medico, medicos.nome_medico
order by total_consultas desc;

-- 5 Mostrar a soma das diarias dos pacientes com sobrenome Silva.

select
pacientes.nome_paciente,
sum(internacoes.valor_diaria) as total_diarias
from pacientes
inner join internacoes
on pacientes.id_paciente = internacoes.id_paciente
where pacientes.nome_paciente like '%Silva%'
group by pacientes.id_paciente, pacientes.nome_paciente;

-- 6 Contar prescricoes de medicamentos.

select 
consultas.status_consulta, 
count(prescricoes.id_prescricao) as quantidade
from consultas
inner join prescricoes
on consultas.id_consulta = prescricoes.id_consulta
where prescricoes.medicamento like '%Dipirona%'
or prescricoes.medicamento like '%Paracetamol%'
group by consultas.status_consulta;

-- 7 Media das diarias em quartos UTI.

select 
pacientes.convenio,
avg(internacoes.valor_diaria) as media
from pacientes
inner join internacoes
on internacoes.id_paciente = pacientes.id_paciente
inner join quartos
on internacoes.id_quarto = quartos.id_quarto
where quartos.tipo_quarto = 'UTI'
group by pacientes.convenio;

-- 8 Media das diarias em quartos UTI.

select
pacientes.convenio,
avg(internacoes.valor_diaria) as media
from pacientes
inner join internacoes 
on pacientes.id_paciente = internacoes.id_paciente
inner join quartos
on internacoes.id_quarto = quartos.id_quarto 
where quartos.tipo_quarto = 'UTI'
group by pacientes.convenio;

-- 9 Quantidade de medicamentos por medico.

select
medicos.nome_medico,
count(prescricoes.id_prescricao) as quantidade
from medicos
inner join consultas 
on medicos.id_medico = consultas.id_medico 
inner join prescricoes
on consultas.id_consulta = prescricoes.id_consulta
where consultas.status_consulta = 'Realizada'
group by medicos.nome_medico;

-- 10 Total e media de consultas por paciente.

select 
pacientes.nome_paciente,
sum(consultas.valor_consulta) as total,
avg(consultas.valor_consulta) as media
from pacientes
inner join consultas  
on pacientes.id_paciente = consultas.id_paciente
where pacientes.nome_paciente like 'M%'
group by pacientes.nome_paciente;

