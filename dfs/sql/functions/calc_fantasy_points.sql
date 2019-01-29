-- ** NEEDS UPDATED ** These sums are pointless after writing update_game_stats.sql
-- I'll need the stats per game anyways, to compute features over the last n weeks.

-- FUNCTION: public.calc_fantasy_points(integer, integer, season_phase)

-- DROP FUNCTION public.calc_fantasy_points(integer, integer, season_phase);

CREATE OR REPLACE FUNCTION public.calc_fantasy_points(
	v_week integer,
	v_year integer,
	v_season_type season_phase)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE
    fd_points real;
    dk_points real;
    game_stats record;
BEGIN

       
    FOR game_stats IN (SELECT gsis_id,
    	   					  player_id,
           					team,
           					SUM(rushing_yds) rushing_yds,
           					SUM(rushing_tds) rushing_tds,
           					SUM(passing_yds) passing_yds,
                    		SUM(passing_tds) passing_tds,
                    		SUM(passing_int) passing_int,
                    		SUM(receiving_yds) receiving_yds,
                    		SUM(receiving_tds) receiving_tds,
                    		SUM(receiving_rec) receiving_rec,
                    		SUM(puntret_tds) puntret_tds,
                    		SUM(kickret_tds) kickret_tds,
                    		SUM(fumbles_lost) fumbles_lost,
                    		SUM(fumbles_rec_tds) fumbles_rec_tds,
                   	 		SUM(passing_twoptm) passing_twoptm,
                    		SUM(rushing_twoptm) rushing_twoptm,
                    		SUM(receiving_twoptm) receiving_twoptm
                       FROM play_player
                       WHERE gsis_id IN (SELECT gsis_id FROM
                                        game WHERE
                                        week = v_week AND
                                        season_year = v_year AND
                                        season_type = v_season_type)
                       GROUP BY gsis_id, player_id, team) LOOP
    	fd_points := game_stats.rushing_yds * 0.1 +
        			 game_stats.rushing_tds * 6 +
                     game_stats.passing_yds * 0.04 +
                     game_stats.passing_int * -2 +
                     game_stats.receiving_yds * 0.1 +
                     game_stats.receiving_tds * 6 +
                     game_stats.receiving_rec * 0.5 +
                     game_stats.puntret_tds * 6 +
                     game_stats.kickret_tds * 6 +
                     game_stats.fumbles_lost * -2 +
                     game_stats.fumbles_rec_tds * 6 +
                     game_stats.passing_twoptm * 2 +
                     game_stats.rushing_twoptm * 2 +
                     game_stats.receiving_twoptm * 2;
    	dk_points := fd_points + game_stats.receiving_rec * 0.5;
        
        INSERT INTO game_player (gsis_id, player_id, team, fanduel_points, draftkings_points)
        VALUES (game_stats.gsis_id, game_stats.player_id, game_stats.team, fd_points, dk_points)
        ON CONFLICT (gsis_id, player_id)
        DO UPDATE SET
            (fanduel_points, draftkings_points)
            = (EXCLUDED.fanduel_points, EXCLUDED.draftkings_points);
    END LOOP;

    RETURN;
END;

$BODY$;

ALTER FUNCTION public.calc_fantasy_points(integer, integer, season_phase)
    OWNER TO postgres;

