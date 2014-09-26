-- Table: mecab_schema
-- DROP TABLE mecab_schema;

CREATE TABLE mecab_schema
(
  face character varying(100), -- 표층형
  tag character varying(50), -- 품사 태그
  mean character varying(50), -- 의미 부류
  final character varying(10), -- 종성 유무
  reading character varying(100), -- 읽기
  ctype character varying(50), -- 타입
  cfirst character varying(10), -- 첫번째 품사
  clast character varying(10), -- 마지막 품사
  origin character varying(100), -- 원형
  cindex character varying(100) -- 인덱스 표현
);
COMMENT ON COLUMN mecab_schema.face IS '표층형';
COMMENT ON COLUMN mecab_schema.tag IS '품사 태그';
COMMENT ON COLUMN mecab_schema.mean IS '의미 부류';
COMMENT ON COLUMN mecab_schema.final IS '종성 유무';
COMMENT ON COLUMN mecab_schema.reading IS '읽기';
COMMENT ON COLUMN mecab_schema.ctype IS '타입';
COMMENT ON COLUMN mecab_schema.cfirst IS '첫번째 품사';
COMMENT ON COLUMN mecab_schema.clast IS '마지막 품사';
COMMENT ON COLUMN mecab_schema.origin IS '원형';
COMMENT ON COLUMN mecab_schema.cindex IS '인덱스 표현';

CREATE TABLE mecab_stack
(
  doc_id bigint,
  seq integer,
  word character varying(100),
  description text
);
