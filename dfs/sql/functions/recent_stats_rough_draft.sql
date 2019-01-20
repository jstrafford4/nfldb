-- FUNCTION: public.compute_recent_player_stats(integer, integer, integer)

-- DROP FUNCTION public.compute_recent_player_stats(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.compute_recent_player_stats(
	p_week integer,
	p_year integer,
	p_last_n_weeks integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE 
 current_player record;
BEGIN
	-- loop through all players
	FOR current_player in (SELECT DISTINCT p.player_id from play_player pp 
		inner join game g on pp.gsis_id = g.gsis_id 
		inner join player p on p.player_id = pp.player_id
		WHERE g.season_year = p_year and g.week >= p_week - 3
		AND p.position IN ['QB'::player_pos, 'RB'::player_pos, 'WR'::player_pos, 'TE'::player_pos) LOOP
                           
        -- for each player, get the last n games they played in                                          
        DROP TABLE IF EXISTS last_n_games;
        CREATE TEMP TABLE last_n_games ON COMMIT DROP AS
        	SELECT * FROM game g
                    INNER JOIN game_player gp
                    WHERE EXISTS (SELECT 1 FROM play_player pp WHERE pp.player_id = current_player.player_id AND pp.gsis_id = g.gsis_id)
                    AND g.season_year = p_year
                    AND g.week < p_week
                    ORDER BY g.week DESC
                    LIMIT p_last_n_weeks;
        
           SELECT AVG(rushing_yds) avg_rush_yds,
                  AVG(rushing_tds) avg_rush_tds,
                  AVG(rushing_att) avg_rush_att,
                  MIN(rushing_yds) min_rush_yds,
                  MIN(rushing_tds) min_rush_tds,
                  MIN(rushing_att) min_rush_att,
                  MIN(rushing_yds) max_rush_yds,
                  MIN(rushing_tds) max_rush_tds,
                  MIN(rushing_att) max_rush_att
          FROM last_n_games;
        
            
		DROP TABLE last_n_games;

    END LOOP;
        
            
 
 RETURN;
END; 

$BODY$;

ALTER FUNCTION public.compute_recent_player_stats(integer, integer, integer)
    OWNER TO postgres;

