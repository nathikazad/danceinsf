import { generateEventInstances } from '../_shared/event-utils.ts'

console.log("Hello from Functions!")


// Edge function handler
Deno.serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    });
  }

  try {
    const { event_ids, date } = await req.json()
    console.log('event_ids is undefined', event_ids == undefined)
    if (event_ids == undefined) {
      console.log('event_ids is undefined')
      throw new Error('event_ids is undefined')
    }
    if (!Array.isArray(event_ids) || event_ids.length === 0) {
      throw new Error('event_ids must be a non-empty array when provided')
    }


    const result = await generateEventInstances(event_ids, date)

    return new Response(
      JSON.stringify(result),
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    )
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred'
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { 
        status: 400,
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        } 
      }
    )
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

 curl -L -X POST 'https://swsvvoysafsqsgtvpnqg.supabase.co/functions/v1/generate_event_instances' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3c3Z2b3lzYWZzcXNndHZwbnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5Mzk1NzgsImV4cCI6MjA2MjUxNTU3OH0.Z3J3KaWt3zd55GSx2fvAZBzd0WRYDWxFzL-eA4X0l54' \
  -H 'Content-Type: application/json' \
  --data '{"event_ids":["8a6d6140-b0d1-4877-8457-b88e9329cb7d"], "date":"2025-05-15T00:00:00.000"}'

*/