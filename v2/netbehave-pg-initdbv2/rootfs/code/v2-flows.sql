

CREATE TABLE  IF NOT EXISTS flow_combined (
	srcips TEXT NOT NULL,
	dstips TEXT NOT NULL,
	protos TEXT NOT NULL,
	srcports TEXT NOT NULL,
	dstports TEXT NOT NULL,

	match_key varchar(200),

	json_data JSONB,

	PRIMARY KEY (srcips, dstips, protos, srcports, dstports)

) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_flow_combined_changetimestamp
	ON public.flow_combined;

CREATE TRIGGER update_flow_combined_changetimestamp BEFORE UPDATE
	ON flow_combined FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();


CREATE TABLE  IF NOT EXISTS flow_rules (
	id_flow_rules SERIAL PRIMARY KEY,
	rulename TEXT NOT NULL,
	rulecsv TEXT NOT NULL,

	json_data JSONB
) INHERITS (timestamp_object);

DROP TRIGGER IF EXISTS update_flow_rules_changetimestamp
	ON public.flow_rules;

CREATE TRIGGER update_flow_rules_changetimestamp BEFORE UPDATE
	ON flow_rules FOR EACH ROW EXECUTE PROCEDURE 
	update_changelast_modified_column();


-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', 'UDP,TCP', '', '53,853', '192.168.0.0/24:/UDP,TCP/8.8.8.8:53,853');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP,TCP', '', '53,853', ':/UDP,TCP/8.8.8.8:53,853');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', 'UDP,TCP', '', '53', '192.168.0.0/24:/UDP,TCP/8.8.8.8:53');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP,TCP', '', '53', ':/UDP,TCP/8.8.8.8:53');
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('', '8.8.8.8', 'UDP', '', '53', ':/UDP/8.8.8.8:53');
-- DELETE FROM flow_combined WHERE match_key = ':/UDP/8.8.8.8:53';
-- INSERT INTO flow_combined (srcips, dstips, protos, srcports, dstports, match_key) VALUES ('192.168.0.0/24', '8.8.8.8', '[UDP,TCP]', '', '[53,853]', '192.168.0.0/24:/[UDP,TCP]/8.8.8.8:[53,853]');

-- INSERT INTO flow_rules (rulename, rulecsv) VALUES ('Google-DNS', 'dst/ip=8.8.8.8,dst/port=53'); 

