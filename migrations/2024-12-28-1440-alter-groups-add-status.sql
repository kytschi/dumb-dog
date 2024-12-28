ALTER TABLE groups ADD status varchar(10) DEFAULT 'active' NULL;
ALTER TABLE groups CHANGE status status varchar(10) DEFAULT 'active' NULL AFTER slug;
