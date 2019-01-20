
    
    
--CREATE TABLE public.feature_ref
--(
--    feature_id serial PRIMARY KEY,
--    name character varying(50) NOT NULL UNIQUE,
--    type feature_type NOT NULL,
--    secondary_type feature_type NULL
--)
--WITH (
--    OIDS = FALSE
--)
--TABLESPACE pg_default;
--
--ALTER TABLE public.feature_ref
--    OWNER to nfldb;


CREATE TABLE public.player_feature
(
	feature_id int NOT NULL,
    player_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    season_year usmallint NOT NULL,
    week usmallint NOT NULL,
    num_weeks usmallint NULL,
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

   CREATE TABLE public.team_feature
(
	feature_id int NOT NULL,
    team_id character varying(3) COLLATE pg_catalog."default" NOT NULL,
    season_year usmallint NOT NULL,
    week usmallint NOT NULL,
    num_weeks usmallint NULL,
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