-- Table: public.feature_ref

-- DROP TABLE public.feature_ref;

CREATE TABLE public.feature_ref
(
    feature_id integer NOT NULL DEFAULT nextval('feature_ref_feature_id_seq'::regclass),
    name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    primary_stat character varying(50) COLLATE pg_catalog."default",
    feature_type feature_type,
    stat_category character varying(25) COLLATE pg_catalog."default",
    CONSTRAINT feature_ref_pkey PRIMARY KEY (feature_id),
    CONSTRAINT feature_ref_name_key UNIQUE (name)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.feature_ref
    OWNER to nfldb;