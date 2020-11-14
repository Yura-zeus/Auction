

CREATE TABLE Roles
(
	id 		SERIAL PRIMARY KEY,
	role	TEXT
);

CREATE TABLE Login
(
	id			SERIAL  	PRIMARY KEY,
	phone		TEXT		NOT NULL UNIQUE,
	Password	char(32)	NOT NULL,
	role		int			NOT NULL REFERENCES Roles
);

--ALTER TABLE Login
--	ADD Unique (phone)
	
COMMENT ON COLUMN Login.phone IS  'Для входа в систему. У staff идет номер удостоверения';
COMMENT ON COLUMN Login.password IS 'Хранится в виде хэша';

INSERT INTO Roles(role) VALUES ('Admin'), ('Exspert'), ('Seller'), ('Customer');

INSERT INTO Login (phone, password, role) VALUES ( 'Admin', '21232f297a57a5a743894a0e4a801fc3',1);  -- password admin



CREATE OR REPLACE FUNCTION authentication (p_number text, p_password text)
							RETURNS TEXT
AS $$
DECLARE 
	v_role text;
BEGIN
	IF char_length(p_password) != 32
		THEN p_password := MD5(p_password);
	END IF;
	
	SELECT r.role INTO STRICT v_role			-- Если не вернет ни одного значения - будет выдана ошибка
	FROM Login l
	INNER JOIN roles r ON  r.id = l.role
	WHERE phone = p_number and password = p_password;

		RETURN v_role;
END;		
$$ LANGUAGE 'plpgsql' STRICT;


