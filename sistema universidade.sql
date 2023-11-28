CREATE TABLE AreasDeEstudo (
    id_area INT AUTO_INCREMENT PRIMARY KEY ,
    nome_area VARCHAR(50)
);


INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(1, 'Ciência da Computação');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(2, 'Engenharia Elétrica');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(3, 'Medicina');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(4, 'Administração');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(5, 'Psicologia');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(6, 'Direito');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(7, 'Biologia');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(8, 'Economia');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(9, 'Arquitetura');
INSERT INTO AreasDeEstudo (id_area, nome_area)VALUES(10, 'Educação Física');

select * from AreasDeEstudo;

CREATE TABLE Cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nome_curso VARCHAR(50),
    id_area INT,
    FOREIGN KEY (id_area) REFERENCES AreasDeEstudo(id_area)
);

select * from Cursos;

CREATE TABLE Alunos (
  id_aluno INT AUTO_INCREMENT PRIMARY KEY,
  nome_aluno VARCHAR(50) NOT NULL,
  id_curso INT NOT NULL,
   FOREIGN KEY (id_curso) REFERENCES Cursos(id_curso)
);
ALTER TABLE Alunos
MODIFY id_curso INT NOT NULL DEFAULT 0;
 
select * from Alunos;

-- Stored Procedure para inserir um curso
DELIMITER //

CREATE PROCEDURE InserirCurso (
    IN nome_curso VARCHAR(50),
    IN id_area INT
)
BEGIN
    INSERT INTO Cursos (nome_curso, id_area)
    VALUES (nome_curso, id_area);
END //

DELIMITER ;

ALTER TABLE Alunos
ADD COLUMN email_aluno VARCHAR(100) GENERATED ALWAYS AS (CONCAT(nome_aluno, '@dominio.com')) STORED;

DELIMITER //
CREATE TRIGGER before_insert_Alunos
BEFORE INSERT ON Alunos
FOR EACH ROW
BEGIN

  SET NEW.email_aluno = CONCAT(NEW.nome_aluno, '@dominio.com');
END;
//

delimiter $
CREATE DEFINER=`root`@`localhost` FUNCTION `obter_id_curso`(
  p_nome_curso VARCHAR(100),
  p_area_curso VARCHAR(100)
) RETURNS int
    DETERMINISTIC
BEGIN
  DECLARE curso_id INT;
  
  SELECT idCursos INTO curso_id
  FROM Cursos
  WHERE nome = p_nome_curso AND area = p_area_curso;
  
  RETURN curso_id;
END



-
DELIMITER //

CREATE PROCEDURE RealizarMatricula (
    IN nome_aluno_param VARCHAR(50),
    IN nome_curso_param VARCHAR(50),
    IN id_area_param INT
)
BEGIN
    DECLARE id_aluno_param INT;
    DECLARE id_curso_param INT;

    -- Verificar se o aluno já está matriculado
    SELECT id_aluno INTO id_aluno_param
    FROM Alunos
    WHERE nome_aluno = nome_aluno_param
    LIMIT 1;

    IF id_aluno_param IS NOT NULL THEN
        -- O aluno já está matriculado, a matrícula não pode ser realizada
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Este aluno já está matriculado em um curso.';
    ELSE
        -- Inserir o novo aluno na tabela Alunos
        INSERT INTO Alunos (nome_aluno) VALUES (nome_aluno_param);

        -- Obter o ID do aluno recém-inserido
        SET id_aluno_param = LAST_INSERT_ID();

        -- Obter o ID do curso
        SET id_curso_param = obter_id_curso(nome_curso_param, id_area_param);

        IF id_curso_param IS NOT NULL THEN
            -- Inserir a matrícula associando o aluno ao curso na tabela Matriculas
            INSERT INTO Matriculas (id_aluno, id_curso) VALUES (id_aluno_param, id_curso_param);
        ELSE
            -- O curso não foi encontrado
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'O curso especificado não foi encontrado.';
        END IF;
    END IF;
END //

DELIMITER ;
