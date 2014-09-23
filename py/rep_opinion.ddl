-- Needed unique key for identifying row(record).
CREATE SEQUENCE water_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 4
  CACHE 1;

-- raw data set
CREATE TABLE water_korea_train
(
  seq bigint DEFAULT nextval('water_seq'::regclass),
  gettm timestamp,
  doctm timestamp, 
  target character varying(100),
  num bigint,
  link character varying(300),
  body text,
  rep character varying(10)
);
