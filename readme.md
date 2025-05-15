To deploy the website
firebase deploy

To create a new migration
supabase migration new modify_event_systems2
supabase migration push

supabase migration squash --db-url postgresql://postgres.swsvvoysafsqsgtvpnqg:[Password]@aws-0-us-west-1.pooler.supabase.com:6543/postgres

To sync local migrations with remote
 supabase db pull

flutter run -d chrome