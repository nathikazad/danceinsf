import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7';
import { generateEventInstances } from "../_shared/event-utils.ts";

// Hardcode your env variables here
Deno.env.set("SUPABASE_URL", "https://swsvvoysafsqsgtvpnqg.supabase.co");
Deno.env.set("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3c3Z2b3lzYWZzcXNndHZwbnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5Mzk1NzgsImV4cCI6MjA2MjUxNTU3OH0.Z3J3KaWt3zd55GSx2fvAZBzd0WRYDWxFzL-eA4X0l54");

async function main() {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    );

    // Fetch all non-archived events
  // const eventIds = ["99f4af0a-f38c-4c70-840f-3dd0c43e0bad"];
  const eventIds: string[] = [];

  let eventsQuery = supabaseClient
    .from('events')
    .select('*')
    .eq('is_archived', false)

  if (eventIds !== null && eventIds.length > 0) {
    eventsQuery = eventsQuery.in('event_id', eventIds)
  }

  const { data: events, error } = await eventsQuery

    if (error) {
      console.error('Error fetching events:', error);
      return;
    }

    if (!events || events.length === 0) {
      console.log('No active events found');
      return;
    }

    console.log(`Found ${events.length} active events`);
    
    // Log event details
    events.forEach(event => {
      console.log('Event:', {
        id: event.event_id,
        name: event.name,
        recurrence_type: event.recurrence_type,
        monthly_pattern: event.monthly_pattern,
        weekly_pattern: event.weekly_days,
      });
    });

    // Generate instances for all events
    // const result = await generateEventInstances();
    const result = await generateEventInstances(eventIds)
    console.log("Result:", result);
  } catch (err) {
    console.error("Error:", err);
  }
}

main();