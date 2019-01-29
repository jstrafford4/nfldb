-- Table: public.team_feature

-- DROP TABLE public.team_feature;

CREATE TABLE public.team_feature
(
    feature_id integer NOT NULL,
    team_id character varying(3) COLLATE pg_catalog."default" NOT NULL,
    season_year usmallint NOT NULL,
    week usmallint NOT NULL,
    num_weeks usmallint NOT NULL,
    CONSTRAINT team_feature_pkey PRIMARY KEY (feature_id, team_id, season_year, week, num_weeks),
    CONSTRAINT team_feature_fid FOREIGN KEY (feature_id)
        REFERENCES public.feature_ref (feature_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT team_feature_tid FOREIGN KEY (team_id)
        REFERENCES public.team (team_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.team_feature
    OWNER to nfldb;