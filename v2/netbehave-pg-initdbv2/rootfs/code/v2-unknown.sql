-- For any unknown info that must be looked for async or manual (e.g. DNS, Net Block, ... not limited to those)

CREATE TABLE  IF NOT EXISTS unknown (
  unknown_type		TEXT NOT NULL,
  unknown_key		TEXT NOT NULL,
  status			TEXT NOT NULL,  
  json_data 		JSONB,
  PRIMARY KEY (unknown_type, unknown_key)
) INHERITS (timestamp_object);



