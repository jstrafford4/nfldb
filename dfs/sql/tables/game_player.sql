-- Table: public.game_player

-- DROP TABLE public.game_player;

CREATE TABLE public.game_player
(
    gsis_id gameid COLLATE pg_catalog."default" NOT NULL,
    player_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    team character varying(3) COLLATE pg_catalog."default" NOT NULL,
    fanduel_points real,
    fanduel_salary integer,
    draftkings_points real,
    draftkings_salary integer,
    fd_5wk_standard_units real,
    dk_5wk_standard_units real,
    CONSTRAINT game_player_pkey PRIMARY KEY (gsis_id, player_id),
    CONSTRAINT game_player_gsis_id_fkey FOREIGN KEY (gsis_id)
        REFERENCES public.game (gsis_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT game_player_player_id_fkey FOREIGN KEY (player_id)
        REFERENCES public.player (player_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT play_player_team_fkey FOREIGN KEY (team)
        REFERENCES public.team (team_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.game_player
    OWNER to nfldb;