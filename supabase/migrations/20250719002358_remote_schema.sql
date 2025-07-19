drop view if exists "public"."event_ratings";

alter table "public"."event_instances" alter column "description" set data type jsonb using "description"::jsonb;

alter table "public"."events" add column "extras" jsonb default '{}'::jsonb;

alter table "public"."events" add column "gps" jsonb;

alter table "public"."events" alter column "default_description" set default '{}'::jsonb;

alter table "public"."events" alter column "default_description" set data type jsonb using "default_description"::jsonb;

alter table "public"."logs" add column "zone" text not null default 'San Francisco'::text;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_session_counts(session_ids uuid[])
 RETURNS TABLE(session_id text, count bigint)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  select session_id, count(*)
  from logs
  where session_id = any(session_ids)
  group by session_id;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_counts(user_ids uuid[])
 RETURNS TABLE(user_id text, count bigint)
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  select user_id, count(*)
  from logs
  where user_id = any(user_ids)
  group by user_id;
$function$
;

create or replace view "public"."event_ratings" as  SELECT e.event_id,
    COALESCE(avg(r.rating), (0)::numeric) AS average_rating,
    count(r.rating) AS rating_count
   FROM ((events e
     LEFT JOIN event_instances i ON ((e.event_id = i.event_id)))
     LEFT JOIN instance_ratings r ON ((i.instance_id = r.instance_id)))
  GROUP BY e.event_id;



