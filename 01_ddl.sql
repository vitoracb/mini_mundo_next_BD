
--  Escolha de Tema & Modelagem ER (Aula 2) - Crie um mini-mundo autoral (ex: clínica médica, oficina, biblioteca). 
-- Desenhe o diagrama ER completo no brModelo contendo 4+ tabelas e pelo menos uma relação N:N.

create database organiza_odonto;

create table pacientes (
    id_paciente int generated always as identity primary key,
    nome varchar(50) not null,
    telefone varchar(11),
    endereco varchar(100),
    cpf varchar(11) unique not null
);

create table dentistas (
    id_dentista int generated always as identity primary key,
    nome varchar(50) not null
);

create table clinicas (
    id_clinica int generated always as identity primary key,
    nome varchar(50) not null
);

create table procedimentos (
    id_procedimento int generated always as identity primary key,
    nome varchar(50) not null,
    preco numeric(10,2) not null
);

create table agendamentos (
    id_agendamento int generated always as identity primary key,
    data date not null,
    hora time not null, 
    status varchar(50) not null,
    id_paciente int not null references pacientes(id_paciente),
    id_clinica int not null references clinicas(id_clinica),
    id_dentista int not null references dentistas(id_dentista)
);

create table agendamento_procedimento (
    id_agendamento int not null references agendamentos(id_agendamento), 
    id_procedimento int not null references procedimentos(id_procedimento),
    status varchar(50),
    primary key(id_agendamento, id_procedimento)
);

create table dentista_clinica (
    id_dentista int not null references dentistas(id_dentista),
    id_clinica int not null references clinicas(id_clinica),
    primary key(id_dentista, id_clinica)
);


-- 2 - Mapeamento & Script DDL/DML (Aulas 3 e 4) - Escreva o script SQL estruturado e limpo para criar as tabelas com constraints (PK, FK, NOT NULL) 
-- e povoe-as com pelo menos 5+ registros cada (com lado sem par).

insert into pacientes (nome, telefone, endereco, cpf) values
('Jimmy Hendrix', '71998888888', 'Aldeia de Arembepe, 420', '03251727809'),
('Michael Jackson', '11999999999', 'Avenida Paulista, 518', '09988877766'),
('Bob Marley', '81977777777', 'Rua da Aurora 222', '65432187656'),
('John Lennon', '21998765467', 'Avenida Brasil 321', '76534567898'),
('Gilberto Gil', '71998765432', 'Avenida Centenário 98', '04456776587'); 

insert into dentistas (nome) values
('Bárbara Queiroz'),
('Bruno Queiroz'),
('Pedro Bueno'),
('João da Silva'),
('Vitória Duarte'); 

insert into clinicas (nome) values
('Clínica Essência'),
('ArtOdonto'),
('Odontocompany'),
('Viver Sorrindo'),
('Clínica Data');

insert into procedimentos (nome, preco) values
('Limpeza', 100.00),
('Tratamento de Canal', 500.00),
('Aparelho Ortodôntico', 2000.00),
('Restauração', 350.00),    
('Placa Bruxismo', 1000.00);

insert into agendamentos (data, hora, status, id_paciente, id_clinica, id_dentista) values
('2026-07-24', '08:20', 'COMPARECEU', 1, 1, 1),
('2026-09-13', '12:00', 'AGENDADO', 2, 2, 2), 
('2026-12-12', '13:00', 'AGENDADO', 3, 3, 3), 
('2026-01-03', '09:00', 'REALIZADO', 4,4,4),
('2026-04-05', '10:00', 'CANCELADO', 5, 5, 5);

insert into agendamento_procedimento (id_agendamento, id_procedimento, status) values
(1, 1, 'FINALIZADO'),
(1, 3, 'FINALIZADO'),
(2, 2, 'EM ANDAMENTO'), 
(3, 4, 'FINALIZADO'), 
(4, 1, 'EM ANDAMENTO');

insert into dentista_clinica (id_dentista, id_clinica) values
(1, 1),
(1, 2),
(2, 3), 
(3, 4),
(4, 5);


-- 3 - Bateria de 10 Consultas Práticas (Aulas 5 a 7) - Resolva 10 enunciados de relatórios úteis do seu negócio utilizando filtros variados, agregações, 
-- GROUP BY, JOIN duplo (3 tabelas), LEFT JOIN (mostrando NULL), CTE e Window Function.


-- 1. Pacientes cujo nome contém "on" (filtro com LIKE)

select p.nome 
from pacientes p
where p.nome like '%on%'
;

-- 2. Agendamentos entre duas datas (filtro com BETWEEN)

select a.data, a.hora, a.status
from agendamentos a
where a.data between '2026-01-01' and '2026-09-01'
;

-- 3. Quantidade de agendamentos por dentista (COUNT + GROUP BY + JOIN)

select d.nome, 
    count(a.id_agendamento) as total_agendamentos
from dentistas d 
join agendamentos a on a.id_dentista = d.id_dentista
group by d.nome
;

-- 4. Faturamento total por procedimento (SUM + GROUP BY + JOIN)

select p.nome as procedimento, 
    sum (p.preco) as faturamento_total
from procedimentos p
join agendamento_procedimento ap on p.id_procedimento = ap.id_procedimento
group by p.nome
order by faturamento_total
;

-- 5. Relatório completo de agendamentos: paciente, dentista e clínica (JOIN de 4 tabelas)

select a.data, 
	a.hora,
	p.nome as paciente, 
	c.nome as clinicas,
	d.nome as dentista
from agendamentos a
inner join pacientes p on p.id_paciente = a.id_paciente
inner join clinicas c on c.id_clinica = a.id_clinica
inner join dentistas d on d.id_dentista = a.id_dentista 
order by a.data
;

-- 6. Procedimentos que nunca foram agendados (LEFT JOIN mostrando NULL)

select p.nome as procedimento
from procedimentos p
left join agendamento_procedimento ap on p.id_procedimento = ap.id_procedimento 
where ap.id_procedimento  is null
;

-- 7. Dentistas que não atendem em nenhuma clínica (LEFT JOIN mostrando NULL)

select d.nome as dentista,
	c.nome as clinica
from dentistas d
left join dentista_clinica dc on d.id_dentista = dc.id_dentista 
left join clinicas c on c.id_clinica = dc.id_clinica 
where c.id_clinica is null
;

-- 8. Procedimentos com preço acima da média (CTE)

with media as (
	select avg(p.preco) as preco_medio
	from procedimentos p
)
select p.nome,
	p.preco    
from procedimentos p, media
where p.preco > media.preco_medio
;

-- 9. Ranking dos procedimentos do mais caro ao mais barato (Window Function - RANK)

select p.nome as procedimento,
	p.preco,
	rank() over(order by p.preco desc) as ranking
from procedimentos p
order by ranking asc
;

-- 10. Total de agendamentos por clínica (COUNT + GROUP BY)
                              
select c.nome as clinica,
	count(a.id_agendamento) as total_agendamentos
from agendamentos a
inner join clinicas c on c.id_clinica = a.id_clinica 
group by c.nome
order by total_agendamentos desc
;