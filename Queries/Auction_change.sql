-- 13.11.2020
CREATE EXTENSION dblink;  	-- Подключение к другой БД

ALTER TABLE public.expert 
	ADD COLUMN idpolzovately int REFERENCES Polzovately; 

ALTER TABLE public.polzovately
  ADD UNIQUE (email),
  ADD UNIQUE (telefon);
   
CREATE TABLE Staff
(
	id			SERIAL PRIMARY KEY,
	udoslich 	text  NOT NULL UNIQUE,
    name 		text  NOT NULL,
    surname 	text  NOT NULL
);
	
INSERT INTO Staff (udoslich, name, surname) values ('admin', 'Yura', 'Rudenko');

-- Update| Insert
UPDATE Expert
	SET idpolzovately = CASE idexpert 
							when  1 then 14
							when 2 then 15
							when 3 then 16
						end;
						
-- Queries
CREATE OR REPLACE View roles as
(
	SELECT pol.*, 	CASE 
						WHEN prod.idpolzovately IS NOT NULL THEN True 
						ELSE False
					END Prodavec,
					CASE 
						WHEN pok.idpolzovately IS NOT NULL THEN True 
						ELSE False
					END Pokupatel,
					CASE 
						WHEN ex.idpolzovately IS NOT NULL THEN True
						ELSE False
					END Expert
					
	FROM polzovately pol
	LEFT JOIN prodavec prod ON pol.id = prod.idpolzovately
	LEFT JOIN pokupatel pok ON pol.id = pok.idpolzovately
	LEFT JOIN expert	ex  ON pol.id = ex.idpolzovately
);


CREATE OR REPLACE FUNCTION add_user(p_name text, p_surname text, p_password text, p_udoslich text, p_phone text, p_email text)
							RETURNS Void
AS $$
	DECLARE
		v_idpolzovately int;
		new_user text;
BEGIN
	IF p_email NOT LIKE '%@%' 
		THEN RAISE EXCEPTION 'Некорректный email';
	END IF;
	
	IF char_length(p_phone) != 13 
		THEN RAISE EXCEPTION 'Некорректный номер телефона';
	END IF;
	
	IF char_length(p_password) != 32
		THEN p_password := MD5(p_password);
	END IF;
	
	INSERT INTO polzovately (udoslich, name, surname, email, telefon)
			VALUES (p_udoslich, p_name, p_surname, p_email, p_phone)
	RETURNING id INTO v_idpolzovately;
			
	INSERT INTO pokupatel (idpolzovately) VALUES (v_idpolzovately);
	
	new_user= 'INSERT INTO Login (phone, password, role) VALUES ('''|| p_phone ||''', '''|| p_password || ''', 4)';
	RAISE NOTICE '%', new_user;
	
	PERFORM dblink_exec('dbname=users host=localhost port=5433 user=postgres password=postgres',new_user);							-- !!! Поменять на 5432
	
END;
$$ LANGUAGE 'plpgsql';
	
COMMENT ON FUNCTION  add_user IS 'Регистрация пользователя как покупателя. 
								Для регистрации продавца пользователь отпарвляет заявку администратору. 
								Для регистрации эксперта, администратор лично создает в личном кабинете';
								
 