CREATE TABLE IF NOT EXISTS public.timestamp_object (
  date_added    TIMESTAMP DEFAULT NOW(),
  last_seen 	TIMESTAMP DEFAULT NOW(),
  last_modified	TIMESTAMP DEFAULT NOW()
);


  
  
CREATE OR REPLACE FUNCTION update_changelast_modified_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.last_modified = now(); 
   RETURN NEW;
END;
$$ language 'plpgsql';


DROP TRIGGER IF EXISTS update_timestamp_object_changetimestamp
	ON public.timestamp_object;

CREATE TRIGGER update_timestamp_object_changetimestamp BEFORE UPDATE
    ON public.timestamp_object FOR EACH ROW EXECUTE PROCEDURE 
    update_changelast_modified_column();



-- TODO: trigger for UPDATE to save old/new values
CREATE TABLE IF NOT EXISTS public.v2_log (
  table_name TEXT,
  table_field TEXT,
  table_key TEXT,
  table_key_value TEXT,
  old_value TEXT,
  new_value TEXT,
  date_added    TIMESTAMP DEFAULT NOW()
);
