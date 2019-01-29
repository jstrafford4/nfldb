-- FUNCTION: public.calc_def_fantasy_points(integer, integer, season_phase)

-- DROP FUNCTION public.calc_def_fantasy_points(integer, integer, season_phase);

CREATE OR REPLACE FUNCTION public.calc_def_fantasy_points(
	v_week integer,
	v_year integer,
	v_season_type season_phase DEFAULT 'Regular'::season_phase)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 0
AS $BODY$

DECLARE
    fd_points real;
    dk_points real;
    pts_against real;
    def_team varchar(3);
    def_player_id varchar(10);
    possession_stats record;
BEGIN

    DROP TABLE IF EXISTS pos_team_stats;
        CREATE TEMP TABLE pos_team_stats ON COMMIT DROP AS
            SELECT g.gsis_id,
                   g.home_team,
                   g.away_team,
                   d.pos_team,
                    SUM(ap.defense_sk) sacks,
                    SUM(ap.defense_frec) recoveries,
                    SUM(ap.defense_frec_tds) + SUM(ap.defense_int_tds) turnover_tds,
                    SUM(ap.defense_int) interceptions,
                    SUM(ap.defense_xpblk) + SUM(ap.defense_puntblk) + SUM(ap.defense_fgblk) blocked_kicks,
                    SUM(ap.defense_safe) safeties,
                    SUM(ap.kickret_tds) kickret_tds,
                    SUM(ap.puntret_tds) puntret_tds,
                    -- not sure if this is 2 pt/xp returned, or just a catch-all bucket
                    SUM(ap.defense_misc_tds) misc_tds,
                    -- below here is offensive points against
                    SUM(ap.rushing_tds) rush_tds,
                    SUM(ap.receiving_tds) rec_tds,
                    SUM(ap.fumbles_rec_tds) fum_tds,
                    SUM(ap.rushing_twoptm) rush_2pm,
                    SUM(ap.receiving_twoptm) rec_2pm,
                    SUM(ap.kicking_fgm) field_goals,
                    SUM(ap.kicking_xpmade) xpoints
            FROM game g
                INNER JOIN drive d ON g.gsis_id = d.gsis_id
                INNER JOIN agg_play ap ON ap.drive_id = d.drive_id
                					  AND ap.gsis_id = d.gsis_id
            WHERE g.week = v_week
                AND g.season_year = v_year
                AND g.season_type = v_season_type
            GROUP BY g.gsis_id, d.pos_team;

    FOR possession_stats IN (SELECT * FROM pos_team_stats) LOOP

        fd_points :=    (possession_stats.sacks * 1) +
                        (possession_stats.recoveries * 2) +
                        (possession_stats.turnover_tds * 6) +
                        (possession_stats.interceptions * 2) +
                        (possession_stats.blocked_kicks * 2) +
                        (possession_stats.safeties * 2) +
                        (possession_stats.kickret_tds * 2) +
                        (possession_stats.puntret_tds * 2) +
                        (possession_stats.misc_tds * 2);

        pts_against :=  (possession_stats.rush_tds * 6) +
                        (possession_stats.rec_tds * 6) +
                        (possession_stats.fum_tds * 6) +
                        (possession_stats.rush_2pm * 2) +
                        (possession_stats.rec_2pm * 2) +
                        (possession_stats.field_goals * 3) +
                        (possession_stats.xpoints);

        IF pts_against = 0 THEN
            fd_points := fd_points + 10;
        ELSIF pts_against <= 6 THEN
            fd_points := fd_points + 7;
        ELSIF pts_against <= 13 THEN
            fd_points := fd_points + 4;
        ELSIF pts_against <= 20 THEN
            fd_points := fd_points + 1;
        ELSEIF pts_against <= 27 THEN
            fd_points := fd_points + 0; -- I know
        ELSEIF pts_against <= 34 THEN
            fd_points := fd_points - 1;
        ELSE
            fd_points := fd_points - 4;
        END IF;

        -- I believe they score defenses equally
        dk_points := fd_points;

        IF possession_stats.pos_team = possession_stats.home_team THEN
            def_team := possession_stats.away_team;
        ELSE
            def_team := possession_stats.home_team;
        END IF;

        IF char_length(def_team) = 2 THEN
            def_player_id := '00-00000' || def_team;
        ELSIF char_length(def_team) = 3 THEN
            def_player_id := '00-0000' || def_team;
        END IF;

        INSERT INTO game_player (gsis_id, player_id, team, fanduel_points, draftkings_points)
        VALUES (possession_stats.gsis_id, def_player_id, def_team, fd_points, dk_points)
        ON CONFLICT (gsis_id, player_id)
        DO UPDATE SET
            (fanduel_points, draftkings_points)
            = (EXCLUDED.fanduel_points, EXCLUDED.draftkings_points);

    END LOOP;

    RETURN;
END;

$BODY$;

ALTER FUNCTION public.calc_def_fantasy_points(integer, integer, season_phase)
    OWNER TO postgres;

