CREATE DATABASE	bdLocadora
GO
USE bdLocadora

CREATE TABLE tbEstrela(
	id							INTEGER			NOT NULL
	,	nome 					VARCHAR(40)		NOT NULL
	PRIMARY KEY (id)
);
CREATE TABLE tbCliente(
	numCadastro					INTEGER			NOT NULL
	,	nome					VARCHAR(70)		NOT NULL
	,	logradouro				VARCHAR(150)	NOT NULL
	,	num						INTEGER			NOT NULL	CHECK(num > -1)
	,	cep						CHAR(8)						CHECK(LEN(cep) = 8)
	PRIMARY KEY (numCadastro)
);
CREATE TABLE tbFilme(
	id							INTEGER			NOT NULL
	,	titulo					VARCHAR(40)		NOT NULL
	,	ano						INTEGER						CHECK(ANO < 2022)
	PRIMARY KEY (id)
);
CREATE TABLE tbDvd(
	num							INTEGER			NOT NULL
	,	dataFabricacao			DATE			NOT NULL	CHECK(dataFabricacao < GETDATE())
	,	filmeID					INTEGER			NOT NULL
	PRIMARY KEY (num)
	FOREIGN KEY (filmeId)		REFERENCES tbFilme(id)
);
CREATE TABLE tbFilmeEstrela(
	filmeId						INTEGER			NOT NULL
	,	estrelaId				INTEGER			NOT NULL
	PRIMARY KEY (filmeId,estrelaId)
	FOREIGN KEY (filmeId)		REFERENCES tbFilme(id)
	,	FOREIGN KEY (estrelaId) REFERENCES tbEstrela(id)
);
CREATE TABLE tbLocacao(
	dvdNum						INTEGER			NOT NULL
	,	clienteNumCadastro		INTEGER			NOT NULL
	,	dataLocacao				DATE			NOT NULL	DEFAULT(GETDATE())
	,	dataDevolucao			DATE			NOT NULL
	,	valor					DECIMAL(7,2)	NOT NULL	CHECK(valor > -1)
	PRIMARY KEY (dvdNum,clienteNumCadastro,dataLocacao)
	FOREIGN KEY (dvdNum)						REFERENCES tbDvd(num)
	,	FOREIGN KEY (clienteNumCadastro)		REFERENCES tbCliente(numCadastro)
	,	CONSTRAINT dataLocacaoMaiorDevolucao				CHECK(dataDevolucao	> dataLocacao) 
);
--========================ALTERAÇÕES=========================
ALTER TABLE tbEstrela
ADD nomeReal					VARCHAR(50)

ALTER TABLE tbFilme
ALTER COLUMN titulo				VARCHAR(80)		NOT NULL
--========================INSERTS============================
INSERT INTO tbFilme(id,titulo,ano)
	VALUES
		(1001,'Whiplash',2015)
		,(1002,'Birdman',2015)
		,(1003,'Interestelar',2014)
		,(1004,'A Culpa é das estrelas',2014)
		,(1005,'Alexandre e o Dia Terrível, Horrível, Espantoso e Horroroso',2014)
		,(1006,'Sing',2016)

INSERT INTO tbEstrela(id,nome,nomeReal)
	VALUES 
		(9901,'Michael Keaton','Michael John Douglas')
		,(9902,'Emma Stone','Emily Jean Stone')
		,(9903,'Miles Teller',NULL)
		,(9904,'Steve Carell','Steven John Carell')
		,(9905,'Jennifer Garner','Jennifer Anne Garner')

INSERT INTO tbFilmeEstrela(filmeId,estrelaId)
	VALUES
		(1002  ,9901)
		,(1002 ,9902)
		,(1001 ,9903)
		,(1005 ,9904)
		,(1005 ,9905)

INSERT INTO tbDvd(num,	dataFabricacao, filmeID)
	VALUES
		(10001,'2020-12-02',1001)
		,(10002,'2019-10-18',1002)
		,(10003,'2020-04-03',1003)
		,(10004,'2020-12-02',1001)
		,(10005,'2019-10-18',1004)
		,(10006,'2020-04-03',1002)
		,(10007,'2020-12-02',1005)
		,(10008,'2019-10-18',1002)
		,(10009,'2020-04-03',1003)

INSERT INTO tbCliente(numCadastro,nome,logradouro,num,cep)
	VALUES
		(5501 ,'Matilde Luz','Rua Síria',150,'03086040')
		,(5502 ,'Carlos Carreiro','Rua Bartolomeu Aires',1250,'04419110')	
		,(5503 ,'Daniel Ramalho','Rua Itajutiba',169,NULL)
		,(5504 ,'Roberta Bento','Rua Jayme Von Rosenburg',36,NULL)
		,(5505 ,'Rosa Cerqueira','Rua Arnaldo Simões Pinto',235,'02917110')

INSERT INTO tbLocacao(dvdNum,clienteNumCadastro,dataLocacao,dataDevolucao,valor)
	VALUES
		(10001,5502,'2021-02-18','2021-02-21',3.50)
		,(10009,5502,'2021-02-18','2021-02-21',3.50)
		,(10002,5503,'2021-02-18','2021-02-19',3.50)
		,(10002,5505,'2021-02-20','2021-02-23',3.00)
		,(10004,5505,'2021-02-20','2021-02-23',3.00)
		,(10005,5505,'2021-02-20','2021-02-23',3.00)
		,(10001,5501,'2021-02-24','2021-02-26',3.50)
		,(10008,5501,'2021-02-24','2021-02-26',3.50)
--==============================OPERAÇÕES COM DADOS===========================
UPDATE tbCliente
SET cep = '08411150'
WHERE numCadastro =  5503

UPDATE tbCliente
SET cep = '02918190'
WHERE numCadastro =  5504
--==
UPDATE tbLocacao
SET valor = 3.25
WHERE dataLocacao = '2021-02-18' AND clienteNumCadastro = 5502

UPDATE tbLocacao
SET valor = 3.10
WHERE dataLocacao = '2021-02-24' AND clienteNumCadastro = 5501

--==
UPDATE tbDvd
SET dataFabricacao = '2019-07-14'
WHERE num =  10005
--==
UPDATE tbEstrela
set nomeReal = 'Miles Alexander Teller'
WHERE id = 9903
--==
DELETE FROM tbFilme
WHERE id = 1006

--===============================CONSULTAS=====================================
SELECT 
	id
	,ano
	,CASE WHEN (LEN(titulo) < 11)
	  THEN
		titulo
	  ELSE
		CONVERT(CHAR(10),titulo) + '...'
	  END AS 'Nome do Filme'
FROM tbFilme
WHERE id IN (
	SELECT filmeId
	FROM tbDvd
	WHERE dataFabricacao > '01/01/2020'
)
--============
SELECT 
	num
	,	dataFabricacao
	,	DATEDIFF(MONTH,dataFabricacao,GETDATE()) AS qtd_meses_desde_fabricacao
FROM tbDvd
WHERE filmeID IN (
	SELECT id 
	FROM tbFilme
	WHERE titulo = 'Interestelar'
)
--============
SELECT
	dvdNum
	, dataLocacao
	, dataDevolucao
	, DATEDIFF(DAY,dataLocacao,dataDevolucao) AS 'dias_alugado'
	, valor
FROM tbLocacao
WHERE clienteNumCadastro IN (
	SELECT numCadastro
	FROM tbCliente
	WHERE nome like '%Rosa%'
)
--============
SELECT
	nome
	, logradouro + ', ' + CAST(num AS VARCHAR(8)) AS 'endereço_completo'
	,  SUBSTRING(cep,1,5)+'-'+SUBSTRING(cep,6,3) AS 'cep'
FROM tbCliente
WHERE numCadastro IN(
	SELECT 
		clienteNumCadastro
	FROM tbLocacao
	WHERE dvdNum = 10002
)