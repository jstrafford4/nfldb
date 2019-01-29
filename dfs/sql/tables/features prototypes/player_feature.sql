-- Table: public.player_feature

-- DROP TABLE public.player_feature;

CREATE TABLE public.player_feature
(
    feature_id integer NOT NULL,
    player_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    season_year usmallint NOT NULL,
    week usmallint NOT NULL,
    num_weeks usmallint NOT NULL,
    val double precision,
    CONSTRAINT player_feature_pkey PRIMARY KEY (feature_id, player_id, season_year, week, num_weeks),
    CONSTRAINT player_feature_fid FOREIGN KEY (feature_id)
        REFERENCES public.feature_ref (feature_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT player_feature_pid FOREIGN KEY (player_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.player_feature
    OWNER to nfldb;