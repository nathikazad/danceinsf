import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7';
import { generateEventInstances } from "../_shared/event-utils.ts";

// Hardcode your env variables here
Deno.env.set("SUPABASE_URL", "https://swsvvoysafsqsgtvpnqg.supabase.co");
Deno.env.set("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3c3Z2b3lzYWZzcXNndHZwbnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5Mzk1NzgsImV4cCI6MjA2MjUxNTU3OH0.Z3J3KaWt3zd55GSx2fvAZBzd0WRYDWxFzL-eA4X0l54");

const event_ids = ["e8c55a4c-609b-4694-a0fb-b178daad2064"];
// Optionally, add a date: const date = "2024-05-14";

async function main() {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    );

    // First check if the event exists
    const { data: event, error } = await supabaseClient
      .from('events')
      .select('*')
      .eq('event_id', event_ids[0])
      .single();

    if (error) {
      console.error('Error fetching event:', error);
      return;
    }

    if (!event) {
      console.error('Event not found');
      return;
    }

    console.log('Found event:', {
      id: event.event_id,
      name: event.name,
      is_archived: event.is_archived,
      recurrence_type: event.recurrence_type
    });

    const result = await generateEventInstances(event_ids /*, date */);
    console.log("Result:", result);
  } catch (err) {
    console.error("Error:", err);
  }
}

main();