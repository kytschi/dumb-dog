CREATE TABLE quiet_connections.migrations (
	id INT auto_increment NOT NULL,
	migration varchar(255) NOT NULL,
	created_at DATETIME NOT NULL,
	CONSTRAINT PRIMARY KEY (id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_general_ci;