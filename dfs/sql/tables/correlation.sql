-- Table: public.correlation

-- DROP TABLE public.correlation;

CREATE TABLE public.correlation
(
    player1_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    player2_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    opp_pos player_pos NOT NULL,
    fd_coefficient double precision,
    dk_coefficient double precision,
    past_n_weeks integer NOT NULL,
    week integer NOT NULL,
    season_year integer NOT NULL,
    CONSTRAINT correlation_pkey PRIMARY KEY (player1_id, player2_id, opp_pos, week, season_year, past_n_weeks),
    CONSTRAINT correlation_player1_id_fkey FOREIGN KEY (player1_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT correlation_player2_id_fkey FOREIGN KEY (player2_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.correlation
    OWNER to nfldb;