-- FUNCTION: public.compute_variance(integer, integer, integer)

-- DROP FUNCTION public.compute_variance(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.compute_variance(
	p_week integer,
	p_year integer,
	p_past_n_weeks integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE 
 game_player_row game_player%rowtype;
 fd_var double precision;
 dk_var double precision;
BEGIN

	FOR game_player_row in (SELECT gp.* FROM game_player gp 
                            INNER JOIN game g 
                            ON gp.gsis_id = g.gsis_id
                            INNER JOIN player p
                            ON p.player_id = gp.player_id
                            WHERE p.position IN ('QB', 'RB', 'WR', 'TE')
                            	AND g.week = p_week
                            	AND g.season_year = p_year
                            	AND g.season_type = 'Regular'::season_phase) LOOP
                                
        DROP TABLE IF EXISTS last_n_games;
        CREATE TEMP TABLE last_n_games ON COMMIT DROP AS
        	SELECT gp.* FROM game_player gp
                              	INNER JOIN game g
                              	ON gp.gsis_id = g.gsis_id
                              	WHERE gp.player_id = game_player_row.player_id
             					AND gp.fanduel_points IS NOT NULL
                              	AND g.season_year <= p_year
                              	AND (g.week <= p_week OR g.season_year < p_year)
                              	AND g.season_type = 'Regular'::season_phase
                              	ORDER BY g.season_year DESC, g.week DESC
                                LIMIT p_past_n_weeks;
        
        SELECT INTO fd_var, dk_var
        	   var_samp(fanduel_points), var_samp(draftkings_points)
        FROM last_n_games;
                    
        INSERT INTO player_variance (player_id, team, fd_variance, dk_variance, past_n_weeks, week, season_year)
        VALUES (game_player_row.player_id, game_player_row.team, fd_var, dk_var, p_past_n_weeks, p_week, p_year)
        ON CONFLICT (player_id, past_n_weeks, week, season_year)
        DO UPDATE SET
            (fd_variance, dk_variance)
            = (EXCLUDED.fd_variance, EXCLUDED.dk_variance);
            
    END LOOP;
 
 RETURN;
END; 
$BODY$;

ALTER FUNCTION public.compute_variance(integer, integer, integer)
    OWNER TO postgres;

