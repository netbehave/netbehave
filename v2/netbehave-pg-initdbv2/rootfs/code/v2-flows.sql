

CREATE TABLE  IF NOT EXISTS public.flow_combined (
	srcips TEXT NOT NULL,
	dstips TEXT NOT NULL,
	protos TEXT NOT NULL,
	srcports TEXT NOT NULL,
	dstports TEXT NOT NULL,

	match_key varchar(200),

	json_data JSONB,

	PRIMARY KEY (srcips, dstips, protos, srcports, dstports)

) INHERITS (public.timestamp_object);

DROP TRIGGER IF EXISTS update_flow_combined_changetimestamp
	ON public.flow_combined;

CREATE TRIGGER update_flow_combined_changetimestamp BEFORE UPDATE
	ON public.flow_combined FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();


CREATE TABLE  IF NOT EXISTS public.flow_rules (
	id_flow_rules SERIAL PRIMARY KEY,
	rulename TEXT NOT NULL,
	rulecsv TEXT NOT NULL,

	json_data JSONB
) INHERITS (public.timestamp_object);

DROP TRIGGER IF EXISTS update_flow_rules_changetimestamp
	ON public.flow_rules;

CREATE TRIGGER update_flow_rules_changetimestamp BEFORE UPDATE
	ON public.flow_rules FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();


-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', 'UDP,TCP', '', '53,853', '192.168.0.0/24:/UDP,TCP/8.8.8.8:53,853');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP,TCP', '', '53,853', ':/UDP,TCP/8.8.8.8:53,853');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', 'UDP,TCP', '', '53', '192.168.0.0/24:/UDP,TCP/8.8.8.8:53');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP,TCP', '', '53', ':/UDP,TCP/8.8.8.8:53');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP', '', '53', ':/UDP/8.8.8.8:53');
-- DELETE FROM flow_combined WHERE match_key = ':/UDP/8.8.8.8:53';
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', '[UDP,TCP]', '', '[53,853]', '192.168.0.0/24:/[UDP,TCP]/8.8.8.8:[53,853]');

-- INSERT INTO flow_rules (rulename, rulecsv) VALUES ('Google-DNS', 'dst/ip=8.8.8.8,dst/port=53'); 

-- Categories/rules for tagging traffic
CREATE TABLE  IF NOT EXISTS public.flow_categories (
	id_flow_categories SERIAL PRIMARY KEY,
	cat TEXT NOT NULL,
	subcat TEXT NOT NULL,
	rulecsv TEXT NOT NULL,

	json_data JSONB
) INHERITS (public.timestamp_object);

DROP TRIGGER IF EXISTS update_flow_categories_changetimestamp
	ON public.flow_categories;

CREATE TRIGGER update_flow_categories_changetimestamp BEFORE UPDATE
	ON public.flow_categories FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();
	
-- Categorized traffic
CREATE TABLE  IF NOT EXISTS public.flow_summary (
	srcip varchar(200),
	dstip varchar(200),
	cat TEXT NOT NULL,
	subcat TEXT NOT NULL,
	src_id_host_info 	INT NULL, 
	dst_id_host_info 	INT NULL, 
	id_flow_categories	INT, -- FK
	json_data JSONB,
	PRIMARY KEY (srcip, dstip, cat, subcat)	
) INHERITS (public.timestamp_object);
	
DROP TRIGGER IF EXISTS update_flow_summary_changetimestamp
	ON public.flow_summary;

CREATE TRIGGER update_flow_summary_changetimestamp BEFORE UPDATE
	ON public.flow_summary FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();

-- Categorized traffic (daily)
CREATE TABLE  IF NOT EXISTS public.flow_summary_daily (
	srcip varchar(200),
	dstip varchar(200),
	cat TEXT NOT NULL,
	subcat TEXT NOT NULL,
	datestr char(8),
	src_id_host_info 	INT NULL, 
	dst_id_host_info 	INT NULL, 
	id_flow_categories	INT, -- FK
	json_data JSONB,
	hits int,
	bytes_in bigint,
	bytes_out bigint,
	PRIMARY KEY (srcip, dstip, cat, subcat, datestr)	
) INHERITS (public.timestamp_object);


DROP TRIGGER IF EXISTS update_flow_summary_daily_changetimestamp
	ON public.flow_summary_daily;

CREATE TRIGGER update_flow_summary_daily_changetimestamp BEFORE UPDATE
	ON public.flow_summary_daily FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();

