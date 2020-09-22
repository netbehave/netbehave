CREATE TABLE IF NOT EXISTS host_info (
  id_host_info SERIAL PRIMARY KEY, 
  host_source		TEXT,
  host_source_id	TEXT,
  name				TEXT,
  json_data 		JSONB,
  UNIQUE (host_source, host_source_id)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_host_info_changetimestamp
	ON public.host_info;

CREATE TRIGGER update_host_info_changetimestamp BEFORE UPDATE
    ON host_info FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


CREATE OR REPLACE FUNCTION v2_host_audit() 
	RETURNS TRIGGER AS $v2_host_audit$
    BEGIN
        --
        -- Create a row in emp_audit to reflect the operation performed on emp,
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO v2_log SELECT 'host_info', 'json_data', OLD.json_data, '';
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO v2_log SELECT 'host_info', 'json_data', OLD.json_data, NEW.json_data;
            -- INSERT INTO v2_log SELECT 'U', now(), user, NEW.*;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            -- INSERT INTO v2_log SELECT 'I', now(), user, NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$v2_host_audit$ LANGUAGE plpgsql;

--CREATE OR REPLACE TRIGGER v2_host_audit_trigger
--AFTER INSERT OR UPDATE OR DELETE ON host_info
--    FOR EACH ROW EXECUTE PROCEDURE v2_host_audit

	
CREATE TABLE IF NOT EXISTS host_info_ip (
  id_host_info 	INT, 
  host_source		TEXT,
  host_source_id	TEXT,
  ip				TEXT,
  ip_i				BIGINT,
  intf				TEXT,
  netmask			TEXT,
  UNIQUE (host_source, host_source_id, ip),
  PRIMARY KEY (id_host_info, host_source, host_source_id, ip),
  FOREIGN KEY (id_host_info) REFERENCES host_info (id_host_info)
) INHERITS (timestamp_object);

--  FOREIGN KEY (ip) REFERENCES ip (ip)


DROP TRIGGER IF EXISTS update_host_info_ip_changetimestamp
	ON public.host_info_ip;

CREATE TRIGGER update_host_info_ip_changetimestamp BEFORE UPDATE
    ON host_info_ip FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();
	
CREATE TABLE IF NOT EXISTS host_info_name (
  id_host_info 	INT, 
  host_source		TEXT,
  host_source_id	TEXT,
  name				TEXT,
  PRIMARY KEY (id_host_info, host_source, host_source_id, name),
--  UNIQUE (host_source, host_source_id, name),
  FOREIGN KEY (id_host_info) REFERENCES host_info (id_host_info)
) INHERITS (timestamp_object);


DROP TRIGGER IF EXISTS update_host_info_name_changetimestamp
	ON public.host_info_name;

CREATE TRIGGER update_host_info_name_changetimestamp BEFORE UPDATE
    ON host_info_name FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


CREATE TABLE IF NOT EXISTS host_info_ip_name (
  id_host_info 	INT PRIMARY KEY, 
  host_source		TEXT,
  host_source_id	TEXT,
  ip				TEXT,
  ip_i				BIGINT,
  name				TEXT,  
  UNIQUE (host_source, host_source_id, ip, name)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_host_info_ip_name_changetimestamp
	ON public.host_info_ip_name;

CREATE TRIGGER update_host_info_ip_name_changetimestamp BEFORE UPDATE
    ON host_info_ip_name FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();

-- ?? ALTER TABLE host_info_name ADD CONSTRAINT host_info_name_fk_parent FOREIGN KEY (id_host_info) REFERENCES host_info (id_host_info);


CREATE TABLE IF NOT EXISTS app_info (
  id_app_info SERIAL PRIMARY KEY, 
  app_source	TEXT,
  app_source_id	TEXT,
  app_name			TEXT,
  app_description 	TEXT,
  json_data 	JSONB,
  UNIQUE (app_source, app_source_id)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_app_info_changetimestamp
	ON public.app_info;

CREATE TRIGGER update_app_info_changetimestamp BEFORE UPDATE
    ON app_info FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


CREATE TABLE IF NOT EXISTS app_component (
  id_app_info INT, 
  component_id	TEXT,
  component_type	TEXT,
  json_data 	JSONB,
  PRIMARY KEY (id_app_info, component_id),
  FOREIGN KEY (id_app_info) REFERENCES app_info (id_app_info)

) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_app_component_changetimestamp
	ON public.app_component;

CREATE TRIGGER update_app_component_changetimestamp BEFORE UPDATE
    ON app_component FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();


CREATE TABLE IF NOT EXISTS app_component_host (
  id_app_info INT, 
  component_id	TEXT,
  id_host_info INT,
  component_type	TEXT,
  json_data 	JSONB,
  PRIMARY KEY (id_app_info, component_id, id_host_info),
  FOREIGN KEY (id_app_info, component_id) REFERENCES app_component (id_app_info, component_id)
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_app_component_host_changetimestamp
	ON public.app_component_host;

CREATE TRIGGER update_app_component_host_changetimestamp BEFORE UPDATE
    ON app_component_host FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();
    
CREATE TABLE IF NOT EXISTS host_info_extra (
  id_host_info 	INT, 
  host_source		TEXT,
  host_source_id	TEXT,

  category			TEXT,
  matchkey			TEXT,
  matchvalue		TEXT,
  jsonkey			TEXT,
  json_data 		JSONB,

  FOREIGN KEY (id_host_info) REFERENCES host_info (id_host_info)
) INHERITS (timestamp_object);


DROP TRIGGER IF EXISTS update_host_info_extra_changetimestamp
	ON public.host_info_extra;

CREATE TRIGGER update_host_info_extra_changetimestamp BEFORE UPDATE
    ON host_info_extra FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();

-- host_info_extra_augment

--  UNIQUE (host_source, host_source_id)
--  UNIQUE (host_source, host_source_id, ip),
--  PRIMARY KEY (id_host_info, host_source, host_source_id, ip),
