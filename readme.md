To deploy the website
firebase deploy --only hosting:default
firebase deploy --only hosting:mexico 

To create a new migration
supabase migration new modify_event_systems2
supabase migration push

To sync remote migrations into local
supabase db pull
supabase migration squash --db-url postgresql://postgres.swsvvoysafsqsgtvpnqg:[Password]@aws-0-us-west-1.pooler.supabase.com:6543/postgres