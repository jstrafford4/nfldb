-- Table: public.team_stats

-- DROP TABLE public.team_stats;

CREATE TABLE public.team_stats
(
    team character varying(3) COLLATE pg_catalog."default" NOT NULL,
    week usmallint NOT NULL,
    season_year usmallint NOT NULL,
    season_type season_phase NOT NULL,
    "position" player_pos NOT NULL,
    last_n_weeks integer NOT NULL,
    total_fd_pts real,
    total_dk_pts real,
    fd_avg_std_units real,
    dk_avg_std_units real,
    CONSTRAINT team_stats_pkey PRIMARY KEY (team, week, season_year, season_type, "position", last_n_weeks),
    CONSTRAINT team_stats_team_fkey FOREIGN KEY (team)
        REFERENCES public.team (team_id) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.team_stats
    OWNER to nfldb;