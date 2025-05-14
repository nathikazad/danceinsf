

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) RETURNS TABLE("event_id" "uuid", "average_rating" numeric, "rating_count" bigint)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.event_id,
        COALESCE(AVG(r.rating), 0) as average_rating,
        COUNT(r.rating) as rating_count
    FROM events e
    LEFT JOIN event_instances i ON e.event_id = i.event_id
    LEFT JOIN instance_ratings r ON i.instance_id = r.instance_id
    WHERE e.event_id = ANY(event_ids)
    GROUP BY e.event_id;
END;
$$;


ALTER FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."event_instances" (
    "instance_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "event_id" "uuid",
    "instance_date" "date" NOT NULL,
    "description" "text",
    "start_time" time without time zone,
    "end_time" time without time zone,
    "cost" numeric(10,2),
    "venue_name" character varying(255),
    "city" character varying(100),
    "google_maps_link" "text",
    "ticket_link" "text",
    "flyer_url" "text",
    "special_notes" "text",
    "is_cancelled" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "public"."event_instances" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."events" (
    "event_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "event_type" "text"[],
    "event_category" "text"[],
    "recurrence_type" character varying(20) NOT NULL,
    "recurrence_rule" "text",
    "weekly_days" "text"[],
    "monthly_pattern" "text"[],
    "default_description" "text",
    "default_start_time" time without time zone NOT NULL,
    "default_end_time" time without time zone NOT NULL,
    "default_cost" numeric(10,2),
    "default_venue_name" character varying(255),
    "default_city" character varying(100),
    "default_google_maps_link" "text",
    "default_ticket_link" "text",
    "is_archived" boolean DEFAULT false,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "organizer_ids" "uuid"[] DEFAULT '{}'::"uuid"[]
);


ALTER TABLE "public"."events" OWNER TO "postgres";


COMMENT ON COLUMN "public"."events"."organizer_ids" IS 'Array of user IDs from auth.users table who are organizers of this event';



CREATE TABLE IF NOT EXISTS "public"."instance_ratings" (
    "rating_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "instance_id" "uuid",
    "user_id" "uuid",
    "rating" numeric(3,2),
    "comment" "text",
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "instance_ratings_rating_check" CHECK ((("rating" >= (0)::numeric) AND ("rating" <= (5)::numeric)))
);


ALTER TABLE "public"."instance_ratings" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."event_ratings" AS
 SELECT "e"."event_id",
    COALESCE("avg"("r"."rating"), (0)::numeric) AS "average_rating",
    "count"("r"."rating") AS "rating_count"
   FROM (("public"."events" "e"
     LEFT JOIN "public"."event_instances" "i" ON (("e"."event_id" = "i"."event_id")))
     LEFT JOIN "public"."instance_ratings" "r" ON (("i"."instance_id" = "r"."instance_id")))
  GROUP BY "e"."event_id";


ALTER TABLE "public"."event_ratings" OWNER TO "postgres";


ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_event_id_instance_date_key" UNIQUE ("event_id", "instance_date");



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_pkey" PRIMARY KEY ("instance_id");



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("event_id");



ALTER TABLE ONLY "public"."instance_ratings"
    ADD CONSTRAINT "instance_ratings_pkey" PRIMARY KEY ("rating_id");



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("event_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."instance_ratings"
    ADD CONSTRAINT "instance_ratings_instance_id_fkey" FOREIGN KEY ("instance_id") REFERENCES "public"."event_instances"("instance_id") ON DELETE CASCADE;





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

















































































































































































GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "service_role";


















GRANT ALL ON TABLE "public"."event_instances" TO "anon";
GRANT ALL ON TABLE "public"."event_instances" TO "authenticated";
GRANT ALL ON TABLE "public"."event_instances" TO "service_role";



GRANT ALL ON TABLE "public"."events" TO "anon";
GRANT ALL ON TABLE "public"."events" TO "authenticated";
GRANT ALL ON TABLE "public"."events" TO "service_role";



GRANT ALL ON TABLE "public"."instance_ratings" TO "anon";
GRANT ALL ON TABLE "public"."instance_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."instance_ratings" TO "service_role";



GRANT ALL ON TABLE "public"."event_ratings" TO "anon";
GRANT ALL ON TABLE "public"."event_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."event_ratings" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;

--
-- Dumped schema changes for auth and storage
--

