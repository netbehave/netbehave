CREATE TABLE IF NOT EXISTS net_block (
  ip_start_i		BIGINT,
  ip_end_i			BIGINT,
  ip_start			TEXT,
  ip_end			TEXT,
  net_block_source	TEXT,
  net_block_name	TEXT,
  net_block_mask	TEXT,
  net_block_subnet	TEXT,
  net_block_bits	INT,
  net_block_size	INT,
  json_data 		JSONB,
  PRIMARY KEY (ip_start_i, ip_end_i)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_net_block_changetimestamp
	ON public.net_block;


CREATE TRIGGER update_net_block_changetimestamp BEFORE UPDATE
    ON net_block FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();
	

CREATE TABLE  IF NOT EXISTS ip (
  ip				TEXT	PRIMARY KEY ,
  ip_i				BIGINT NOT NULL,
  ip_version	 	INT NOT NULL, 
  -- optional fields
  id_host_info 	INT,   
  net_block_source	TEXT,
  net_block_name	TEXT,
  json_data 		JSONB
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_ip_changetimestamp
	ON public.ip;

CREATE TRIGGER update_ip_changetimestamp BEFORE UPDATE
    ON ip FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


CREATE TABLE IF NOT EXISTS  ip_listen (
  ip				TEXT NOT NULL,
  ip_i				BIGINT NOT NULL,
  protocol 			TEXT NOT NULL,
  port 				INT NOT NULL,
  ip_version	 	INT, 
  -- optional fields
  service_name 		TEXT,
  id_host_info 		INT,   
  json_data 		JSONB,
  PRIMARY KEY(ip, protocol, port)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_ip_listen_changetimestamp
	ON public.ip_listen;

CREATE TRIGGER update_ip_listen_changetimestamp BEFORE UPDATE
    ON ip_listen FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();

CREATE TABLE IF NOT EXISTS dns_info (
  ip		TEXT,
  ip_i		BIGINT,
  name		TEXT,
  PRIMARY KEY (ip, ip_i, name)
) INHERITS (timestamp_object);

-- need one trigger per table
DROP TRIGGER IF EXISTS update_dns_info_changetimestamp
	ON public.dns_info;

CREATE TRIGGER update_dns_info_changetimestamp BEFORE UPDATE
    ON dns_info FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();

