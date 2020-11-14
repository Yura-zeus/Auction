CREATE ROLE Admin with PASSWORD 'AdMin';
CREATE ROLE Expert with PASSWORD 'ExPeRt';
CREATE ROLE Seller with PASSWORD 'SeLlEr';
CREATE ROLE Customer with PASSWORD 'CuStOmEr';

REVOKE ALL ON database "Auction" FROM PUBLIC;    		-- Для разгранечния прав