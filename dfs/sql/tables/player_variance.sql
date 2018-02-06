-- Table: public.player_variance

-- DROP TABLE public.player_variance;

CREATE TABLE public.player_variance
(
    player_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    team character varying(3) COLLATE pg_catalog."default" NOT NULL,
    fd_variance double precision,
    dk_variance double precision,
    past_n_weeks integer NOT NULL,
    week integer NOT NULL,
    season_year integer NOT NULL,
    CONSTRAINT player_variance_pkey PRIMARY KEY (player_id, week, season_year, past_n_weeks),
    CONSTRAINT variance_player_id_fkey FOREIGN KEY (player_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.player_variance
    OWNER to nfldb;