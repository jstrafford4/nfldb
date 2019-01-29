-- FUNCTION: public.update_game_stats(integer, integer, season_phase)

-- DROP FUNCTION public.update_game_stats(integer, integer, season_phase);

CREATE OR REPLACE FUNCTION public.update_game_stats(
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
    gps record;
BEGIN

	DROP TABLE IF EXISTS player_stats_for_game;
        CREATE TEMP TABLE player_stats_for_game ON COMMIT DROP AS
        	SELECT gsis_id,
    	   		   player_id,
           		   team,
           			SUM(fumbles_tot) fumbles_tot,
                    SUM(kickret_ret) kickret_ret,
                    SUM(kickret_tds) kickret_tds,
                    SUM(kickret_yds) kickret_yds,
                    SUM(passing_att) passing_att,
                    SUM(passing_cmp) passing_cmp,
                    SUM(passing_cmp_air_yds) passing_cmp_air_yds,
                    SUM(passing_incmp) passing_incmp,
                    SUM(passing_incmp_air_yds) passing_incmp_air_yds,
                    SUM(passing_int) passing_int,
                    SUM(passing_sk) passing_sk,
                    SUM(passing_sk_yds) passing_sk_yds,
                    SUM(passing_tds) passing_tds,
                    SUM(passing_yds) passing_yds,
                    SUM(puntret_tot) puntret_tot,
                    SUM(puntret_tds) puntret_tds,
                    SUM(puntret_yds) puntret_yds,
                    SUM(receiving_rec) receiving_rec,
                    SUM(receiving_tar) receiving_tar,
                    SUM(receiving_tds) receiving_tds,
                    SUM(receiving_yac_yds) receiving_yac_yds,
                    SUM(receiving_yds) receiving_yds,
                    SUM(rushing_att) rushing_att,
                    SUM(rushing_loss) rushing_loss,
                    SUM(rushing_loss_yds) rushing_loss_yds,
                    SUM(rushing_tds) rushing_tds,
                    SUM(rushing_yds) rushing_yds
                       FROM play_player
                       WHERE gsis_id IN (SELECT gsis_id FROM
                                        game WHERE
                                        week = v_week AND
                                        season_year = v_year AND
                                        season_type = v_season_type)
                       GROUP BY gsis_id, player_id, team;
                       
        FOR gps in (SELECT * FROM player_stats_for_game)
        LOOP
        	INSERT INTO game_player (gsis_id,player_id,team,fumbles_tot,kickret_ret,kickret_tds,kickret_yds,
                                 passing_att,passing_cmp,passing_cmp_air_yds,passing_incmp,passing_incmp_air_yds,
                                 passing_int,passing_sk,passing_sk_yds,passing_tds,passing_yds,puntret_tot,
                                 puntret_tds,puntret_yds,receiving_rec,receiving_tar,receiving_tds,receiving_yac_yds,
                                 receiving_yds,rushing_att,rushing_loss,rushing_loss_yds,rushing_tds,rushing_yds)
        VALUES (gps.gsis_id, gps.player_id, gps.team, gps.fumbles_tot, gps.kickret_ret, gps.kickret_tds,
                gps.kickret_yds, gps.passing_att, gps.passing_cmp, gps.passing_cmp_air_yds, gps.passing_incmp,
                gps.passing_incmp_air_yds, gps.passing_int, gps.passing_sk, gps.passing_sk_yds, gps.passing_tds,
                gps.passing_yds, gps.puntret_tot, gps.puntret_tds, gps.puntret_yds, gps.receiving_rec, 
                gps.receiving_tar, gps.receiving_tds, gps.receiving_yac_yds, gps.receiving_yds, gps.rushing_att,
                gps.rushing_loss, gps.rushing_loss_yds, gps.rushing_tds, gps.rushing_yds)
        ON CONFLICT (gsis_id, player_id)
        DO UPDATE SET
            (fumbles_tot,kickret_ret,kickret_tds,kickret_yds,
                                 passing_att,passing_cmp,passing_cmp_air_yds,passing_incmp,passing_incmp_air_yds,
                                 passing_int,passing_sk,passing_sk_yds,passing_tds,passing_yds,puntret_tot,
                                 puntret_tds,puntret_yds,receiving_rec,receiving_tar,receiving_tds,receiving_yac_yds,
                                 receiving_yds,rushing_att,rushing_loss,rushing_loss_yds,rushing_tds,rushing_yds)
            = (EXCLUDED.fumbles_tot, EXCLUDED.kickret_ret, EXCLUDED.kickret_tds, EXCLUDED.kickret_yds, 
               EXCLUDED.passing_att, EXCLUDED.passing_cmp, EXCLUDED.passing_cmp_air_yds, EXCLUDED.passing_incmp,
               EXCLUDED.passing_incmp_air_yds, EXCLUDED.passing_int, EXCLUDED.passing_sk, EXCLUDED.passing_sk_yds,
               EXCLUDED.passing_tds, EXCLUDED.passing_yds, EXCLUDED.puntret_tot, EXCLUDED.puntret_tds, 
               EXCLUDED.puntret_yds, EXCLUDED.receiving_rec, EXCLUDED.receiving_tar, EXCLUDED.receiving_tds, 
               EXCLUDED.receiving_yac_yds, EXCLUDED.receiving_yds, EXCLUDED.rushing_att, EXCLUDED.rushing_loss,
               EXCLUDED.rushing_loss_yds, EXCLUDED.rushing_tds, EXCLUDED.rushing_yds);
        END LOOP;

END;

$BODY$;

ALTER FUNCTION public.update_game_stats(integer, integer, season_phase)
    OWNER TO postgres;

