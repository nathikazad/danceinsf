

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






CREATE OR REPLACE FUNCTION "public"."generate_unique_short_url"() RETURNS character varying
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    chars text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result varchar(4);
    i integer;
    exists boolean;
BEGIN
    LOOP
        result := '';
        FOR i IN 1..4 LOOP
            result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
        END LOOP;
        
        -- Check if this code already exists
        SELECT EXISTS (
            SELECT 1 FROM public.event_instances 
            WHERE short_url_prefix = result
        ) INTO exists;
        
        -- If code doesn't exist, return it
        IF NOT exists THEN
            RETURN result;
        END IF;
    END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_unique_short_url"() OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."set_short_url_prefix"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.short_url_prefix := generate_unique_short_url();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_short_url_prefix"() OWNER TO "postgres";

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
    "updated_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "excited_users" "uuid"[] DEFAULT '{}'::"uuid"[] NOT NULL,
    "short_url_prefix" character varying(4)
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
    "organizer_id" "uuid",
    "default_flyer_url" "text",
    "creator_id" "uuid",
    "zone" "text" DEFAULT 'San Francisco '::"text" NOT NULL
);


ALTER TABLE "public"."events" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."logs" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "session_id" "uuid",
    "actions" "jsonb",
    "device" "text",
    "user_id" "uuid"
);


ALTER TABLE "public"."logs" OWNER TO "postgres";


ALTER TABLE "public"."logs" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."logs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."proposals" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "event_id" "uuid",
    "event_instance_id" "uuid",
    "text" "text",
    "resolved" boolean DEFAULT false,
    "yeses" "uuid"[] DEFAULT '{}'::"uuid"[] NOT NULL,
    "nos" "uuid"[] DEFAULT '{}'::"uuid"[],
    "changes" "json" DEFAULT '{}'::"json" NOT NULL
);


ALTER TABLE "public"."proposals" OWNER TO "postgres";


ALTER TABLE "public"."proposals" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."proposals_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_event_id_instance_date_key" UNIQUE ("event_id", "instance_date");



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_pkey" PRIMARY KEY ("instance_id");



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_pkey" PRIMARY KEY ("event_id");



ALTER TABLE ONLY "public"."instance_ratings"
    ADD CONSTRAINT "instance_ratings_pkey" PRIMARY KEY ("rating_id");



ALTER TABLE ONLY "public"."logs"
    ADD CONSTRAINT "logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."proposals"
    ADD CONSTRAINT "proposals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "unique_short_url_prefix" UNIQUE ("short_url_prefix");



CREATE OR REPLACE TRIGGER "set_short_url_prefix_trigger" BEFORE INSERT ON "public"."event_instances" FOR EACH ROW EXECUTE FUNCTION "public"."set_short_url_prefix"();



ALTER TABLE ONLY "public"."event_instances"
    ADD CONSTRAINT "event_instances_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("event_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."events"
    ADD CONSTRAINT "events_organizer_id_fkey" FOREIGN KEY ("organizer_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."instance_ratings"
    ADD CONSTRAINT "instance_ratings_instance_id_fkey" FOREIGN KEY ("instance_id") REFERENCES "public"."event_instances"("instance_id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."logs"
    ADD CONSTRAINT "logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."proposals"
    ADD CONSTRAINT "proposals_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "public"."events"("event_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."proposals"
    ADD CONSTRAINT "proposals_event_instance_id_fkey" FOREIGN KEY ("event_instance_id") REFERENCES "public"."event_instances"("instance_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."proposals"
    ADD CONSTRAINT "proposals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

















































































































































































GRANT ALL ON FUNCTION "public"."generate_unique_short_url"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_unique_short_url"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_unique_short_url"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_event_ratings"("event_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_short_url_prefix"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_short_url_prefix"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_short_url_prefix"() TO "service_role";


















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



GRANT ALL ON TABLE "public"."logs" TO "anon";
GRANT ALL ON TABLE "public"."logs" TO "authenticated";
GRANT ALL ON TABLE "public"."logs" TO "service_role";



GRANT ALL ON SEQUENCE "public"."logs_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."logs_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."logs_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."proposals" TO "anon";
GRANT ALL ON TABLE "public"."proposals" TO "authenticated";
GRANT ALL ON TABLE "public"."proposals" TO "service_role";



GRANT ALL ON SEQUENCE "public"."proposals_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."proposals_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."proposals_id_seq" TO "service_role";









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

