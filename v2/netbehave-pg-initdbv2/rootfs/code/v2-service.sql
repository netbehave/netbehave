		CREATE TABLE IF NOT EXISTS service
		(
			protoPort text COLLATE pg_catalog."default" NOT NULL,
			serviceName text COLLATE pg_catalog."default" NOT NULL,
			serviceDescription text COLLATE pg_catalog."default" NOT NULL,
			PRIMARY KEY (protoPort)

		);

