import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

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
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Get current date in PST
    const now = new Date()
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0, 0)
    
    // Calculate Monday of current week
    const monday = new Date(today)
    const dayOfWeek = today.getDay()
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek // Adjust for Sunday
    monday.setDate(today.getDate() + diff)
    
    // Calculate Sunday of current week
    const sunday = new Date(monday)
    sunday.setDate(monday.getDate() + 6)

    // Fetch events and their instances
    const { data: events, error: eventsError } = await supabaseClient
      .from('event_instances')
      .select(`
        *,
        events!inner(
          name,
          default_venue_name,
          default_city,
          event_type,
          default_start_time
        )
      `)
      .gte('instance_date', monday.toISOString().split('T')[0])
      .lte('instance_date', sunday.toISOString().split('T')[0])
      .contains('events.event_type', ['Social'])
      .order('instance_date', { ascending: true })
      .order('start_time', { ascending: true })

    if (eventsError) {
      throw new Error('Failed to fetch events')
    }

    // Format events into the requested string format
    const formattedEvents = events.map(event => {
      const date = new Date(event.instance_date)
      const dayName = date.toLocaleDateString('en-US', { weekday: 'long' })
      const venueName = event.venue_name || event.events.default_venue_name
      const city = event.city || event.events.default_city
      
      // Format time in AM/PM from default_start_time (hh:mm:ss)
      const [hours, minutes] = event.events.default_start_time.split(':').map(Number)
      const ampm = hours >= 12 ? 'pm' : 'am'
      const formattedHours = hours % 12 || 12
      const formattedTime = minutes === 0 
        ? `${formattedHours}${ampm}`
        : `${formattedHours}:${minutes.toString().padStart(2, '0')}${ampm}`
      
      return `${dayName}: ${event.events.name} (${city}) ${formattedTime} - sfdn.cc/${event.short_url_prefix.toLowerCase()}`
    }).join('\n')

    // Format the date range for the header
    const headerDate = `${monday.toLocaleDateString('en-US', { month: '2-digit', day: '2-digit' })} - ${sunday.toLocaleDateString('en-US', { month: '2-digit', day: '2-digit' })}`
    
    const fullResponse = `Socials for week ${headerDate}\n\n${formattedEvents}\n\nVisit https://wheredothey.dance for more info`

    return new Response(fullResponse, {
      headers: {
        'Content-Type': 'text/plain',
        'Access-Control-Allow-Origin': '*'
      }
    });
  } catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred'
    return new Response(`Error: ${errorMessage}`, {
      status: 500,
      headers: {
        'Content-Type': 'text/plain',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }
})
