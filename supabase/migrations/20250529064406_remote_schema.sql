alter table "public"."event_instances" add column "excited_users" uuid[] not null default '{}'::uuid[];

alter table "public"."events" add column "creator_id" uuid;

alter table "public"."logs" drop column "text";

alter table "public"."logs" add column "actions" jsonb;

alter table "public"."logs" add column "device" text;

alter table "public"."logs" add column "user_id" uuid;

alter table "public"."logs" add constraint "logs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."logs" validate constraint "logs_user_id_fkey";


