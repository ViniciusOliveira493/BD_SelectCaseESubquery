CREATE DATABASE bdProjetos
GO
USE bdProjetos
CREATE TABLE tbProjects(
	id						INTEGER			IDENTITY(10001,1)	NOT NULL
	,	projectName			VARCHAR(45)							NOT NULL
	,	projectDescription	VARCHAR(45)							
	,	projectDate			DATE								NOT NULL	CHECK(projectDate > '01/09/2014')
	PRIMARY KEY (id)
);
CREATE TABLE tbUsers(
	id						INTEGER			IDENTITY(1,1)		NOT NULL
	,	firstName			VARCHAR(45)							NOT NULL
	,	username			VARCHAR(45)		UNIQUE				NOT NULL
	,	passwd				VARCHAR(45)							NOT	NULL	DEFAULT('123mudar')
	,	email				VARCHAR(45)							NOT	NULL
	PRIMARY KEY (id)
);
CREATE TABLE tbUserHasProjcts(
	usersId					INTEGER								NOT NULL
	,	projectsId			INTEGER								NOT NULL
	PRIMARY KEY(usersId,projectsId)	
	FOREIGN KEY (usersId)			REFERENCES tbUsers(id)
	,	FOREIGN KEY (projectsId)	REFERENCES tbProjects(id)
);
--====================================MODIFICAÇÕES============================================
ALTER TABLE tbUsers
DROP CONSTRAINT UQ__tbUsers__F3DBC57207020F21
ALTER TABLE tbUsers
ALTER COLUMN username	VARCHAR(10) NOT NULL
ALTER TABLE tbUsers
ADD CONSTRAINT uniqueUserName UNIQUE (username)

ALTER TABLE tbUsers
ALTER COLUMN passwd			VARCHAR(8)		NOT	NULL
--======================================INSERTS USUÁRIOS================================================
INSERT INTO tbUsers(firstName,username,email)
	VALUES
		('Maria','Rh_maria','maria@empresa.com')
INSERT INTO tbUsers(firstName,username,passwd,email)
	VALUES
		('Paulo','Ti_paulo','123@456','paulo@empresa')
INSERT INTO tbUsers(firstName,username,email)
	VALUES
		('Ana','Rh_ana','ana@empresa.com')
		,('Clara','Ti_clara','clara@empresa.com')
INSERT INTO tbUsers(firstName,username,passwd,email)
	VALUES
		('Aparecido','Rh_apareci','55@!cido','aparecido@empresa.com')

--=======================================INSERTS PROJETOS===============================
INSERT INTO tbProjects(projectName, projectDescription,projectDate)
	VALUES
		('Re-folha','Refatoração das Folhas','05/09/2014')	
		,('Manutenção PC''s','Manutenção PC''s','06/09/2014')
		,('Auditoria',null,'07/09/2014')
--=======================================INSERTS USUARIO_PROJETOS=======================
INSERT INTO tbUserHasProjcts(usersId,projectsId)
	VALUES
		(1,10001)
		,(5,10001)
		,(3,10003)
		,(4,10002)
		,(2,10002)
--=======================================ALTERAÇÃO DADOS================================
UPDATE tbProjects
SET projectDate = '12/09/2014'
WHERE id = 10002

UPDATE tbUsers
SET username = 'Rh_cido'
WHERE firstName = 'Aparecido'

UPDATE tbUsers
SET passwd = '888@*'
WHERE username = 'Rh_maria' AND passwd = '123mudar'

DELETE FROM tbUserHasProjcts
WHERE usersId = 2 AND projectsId = 10002

--=======================================================================================
--==================================Select Case e Subquery===============================
SELECT
	id
	, firstName AS 'Nome'
	, email
	, username
	, CASE(passwd)
		WHEN '123mudar' THEN
			passwd
		ELSE
			'********'
		END as 'password'
FROM tbUsers

--=====
SELECT 
	projectName AS 'Nome do Projeto'
	,	projectDescription AS 'Descrição'
	,	projectDate	AS 'Data'
	,	CASE (id)
		WHEN 10001 THEN
			DATEADD(DAY,15,projectDate) 
		ELSE
			projectDate
		END AS 'Data Final'
FROM tbProjects
WHERE id IN (
	SELECT projectsId 
	FROM tbUserHasProjcts
	WHERE usersId IN (
		SELECT id
		FROM tbUsers
		WHERE email = 'aparecido@empresa.com'
	)
)
--=====
SELECT
	firstName AS 'Nome'
	, email
FROM tbUsers
WHERE id IN (
	SELECT usersId
	FROM tbUserHasProjcts
	WHERE projectsId IN (
		SELECT id
		FROM tbProjects
		WHERE projectName = 'Auditoria'
	)
)
--=====
SELECT
	projectName AS 'Nome'
	,	projectDescription AS 'Descrição'
	,	CONVERT(CHAR(10),projectDate,103) AS 'Data'
	,	'16/09/2014' AS 'Data Final'
	,	CAST(DATEDIFF(DAY,projectDate,'16/09/2014') AS INTEGER)*79.85 AS 'Custo Total'
FROM tbProjects
WHERE projectName LIKE '%Manutenção%'



