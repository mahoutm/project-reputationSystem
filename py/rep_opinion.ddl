-- Needed unique key for identifying row(record).
CREATE SEQUENCE water_train_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 4
  CACHE 1;

-- for test
CREATE SEQUENCE water_test_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 4
  CACHE 1;

-- raw data set
CREATE TABLE water_korea_train
(
  seq bigint DEFAULT nextval('water_train_seq'::regclass),
  gettm timestamp,
  doctm timestamp, 
  target character varying(100),
  num bigint,
  link character varying(300),
  body text,
  rep character varying(10)
);

-- raw data set for test
CREATE TABLE water_korea_test
(
  seq bigint DEFAULT nextval('water_test_seq'::regclass),
  gettm timestamp,
  doctm timestamp, 
  target character varying(100),
  num bigint,
  link character varying(300),
  body text,
  rep character varying(10)
);
