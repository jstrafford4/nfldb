-- FUNCTION: public.get_players(refcursor, integer, integer, integer)

-- DROP FUNCTION public.get_players(refcursor, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.get_players(
	refcursor,
	p_week integer,
	p_year integer,
	p_past_n_weeks integer DEFAULT 5)
    RETURNS refcursor
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

BEGIN
    OPEN $1 FOR 
    	SELECT p.player_id,
        	   p.full_name,
               p.team,
               p.position,
               p.status,
               gp.fanduel_points,
               gp.fanduel_salary,
               gp.draftkings_points,
               gp.draftkings_salary,
               v.fd_variance,
               v.dk_variance
        FROM player p
           INNER JOIN game_player gp ON p.player_id = gp.player_id
           INNER JOIN game gm ON gm.gsis_id = gp.gsis_id
           LEFT JOIN player_variance v ON v.player_id = p.player_id 
           							   AND v.week = gm.week
                                       AND v.season_year = gm.season_year
           WHERE gm.week = p_week
             AND gm.season_year = p_year
             AND gm.season_type = 'Regular'::season_phase
             AND v.past_n_weeks = p_past_n_weeks;
    RETURN $1;
END;

$BODY$;

ALTER FUNCTION public.get_players(refcursor, integer, integer, integer)
    OWNER TO postgres;

