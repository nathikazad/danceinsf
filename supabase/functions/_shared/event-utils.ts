import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

// Types
export interface Event {
  event_id: string
  name: string
  recurrence_type: 'Once' | 'Monthly' | 'Weekly'
  recurrence_rule: string | null
  weekly_days: string[] | null
  monthly_pattern: string[] | null
  default_description: string | null
  default_start_time: string
  default_end_time: string
  default_cost: number | null
  default_venue_name: string | null
  default_city: string | null
  default_google_maps_link: string | null
  default_ticket_link: string | null
}

export interface EventInstance {
  event_id: string
  instance_date: string
  description?: string | null
  start_time?: string | null
  end_time?: string | null
  cost?: number | null
  venue_name?: string | null
  city?: string | null
  google_maps_link?: string | null
  ticket_link?: string | null
}

// Helper function to get the day of week as a number (0 = Sunday, 6 = Saturday)
function getDayOfWeek(date: Date): number {
  return date.getDay()
}

// Helper function to get the day of month
function getDayOfMonth(date: Date): number {
  return date.getDate()
}

// Helper function to get current time in PST
function getCurrentPSTTime(): Date {
  const now = new Date()
  // Set the time to noon to avoid any timezone edge cases
  return new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0, 0)
}

// Helper function to convert any date to PST
function toPST(date: Date): Date {
  // Set the time to noon to avoid any timezone edge cases
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 12, 0, 0)
}

// Helper function to get the week number of the month (1-5)
function getWeekOfMonth(date: Date): number {
  const firstDay = new Date(date.getFullYear(), date.getMonth(), 1)
  const dayOfWeek = firstDay.getDay()
  const dateOfMonth = date.getDate()
  
  // Calculate which week of the month this date falls in
  // If the first day of the month is not Sunday, we need to adjust
  const adjustedDate = dateOfMonth + dayOfWeek
  return Math.ceil(adjustedDate / 7)
}

// Helper function to get the day name
function getDayName(date: Date): string {
  const days = ['Su', 'M', 'Tu', 'W', 'Th', 'F', 'Sa']
  return days[date.getDay()]
}

// Helper function to check if a date matches a monthly pattern
function matchesMonthlyPattern(date: Date, pattern: string): boolean {
  const [week, day] = pattern.split('-')
  const weekNum = parseInt(week)
  const currentWeek = getWeekOfMonth(date)
  const currentDay = getDayName(date)
  
  return currentWeek === weekNum && currentDay === day
}

// Helper function to check if a date matches a weekly pattern
function matchesWeeklyPattern(date: Date, day: string): boolean {
  return getDayName(date) === day
}

// Function to generate instances for a one-time event
function generateOnceInstance(event: Event, date: string): EventInstance {
  return {
    event_id: event.event_id,
    instance_date: date,
  }
}

// Function to generate instances for a weekly event
function generateWeeklyInstances(event: Event, startDate: Date, endDate: Date): EventInstance[] {
  const instances: EventInstance[] = []
  const currentDate = toPST(startDate)
  const pstEndDate = toPST(endDate)

  while (currentDate <= pstEndDate) {
    if (event.weekly_days?.includes(getDayName(currentDate))) {
      instances.push({
        event_id: event.event_id,
        instance_date: currentDate.toISOString().split('T')[0],
      })
    }
    currentDate.setDate(currentDate.getDate() + 1)
  }

  return instances
}

// Function to generate instances for a monthly event
function generateMonthlyInstances(event: Event, startDate: Date, endDate: Date): EventInstance[] {
  const instances: EventInstance[] = []
  const currentDate = toPST(startDate)
  const pstEndDate = toPST(endDate)

  while (currentDate <= pstEndDate) {
    if (event.monthly_pattern?.some(pattern => matchesMonthlyPattern(currentDate, pattern))) {
      instances.push({
        event_id: event.event_id,
        instance_date: currentDate.toISOString().split('T')[0],
      })
    }
    currentDate.setDate(currentDate.getDate() + 1)
  }

  return instances
}

// Main function to generate event instances
export async function generateEventInstances(eventIds?: string[], date?: string) {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  )

  // Fetch events based on whether eventIds is provided
  let eventsQuery = supabaseClient
    .from('events')
    .select('*')
    .eq('is_archived', false)

  if (eventIds && eventIds.length > 0) {
    eventsQuery = eventsQuery.in('event_id', eventIds)
  }

  const { data: events, error: eventsError } = await eventsQuery

  if (eventsError || !events || events.length === 0) {
    throw new Error('No events found')
  }

  // Calculate date range in PST
  const today = getCurrentPSTTime()
  const endDate = new Date(today)
  endDate.setDate(today.getDate() + 30) // Generate instances for next 30 days

  // Fetch all existing instances for these events in the date range
  const { data: existingInstances, error: fetchError } = await supabaseClient
    .from('event_instances')
    .select('event_id, instance_date')
    .in('event_id', events.map(e => e.event_id))
    .gte('instance_date', today.toISOString().split('T')[0])
    .lte('instance_date', endDate.toISOString().split('T')[0])

  if (fetchError) {
    throw new Error('Failed to check for existing instances')
  }

  // Create a map of existing instances for quick lookup
  const existingInstancesMap = new Map<string, Set<string>>()
  existingInstances?.forEach(instance => {
    if (!existingInstancesMap.has(instance.event_id)) {
      existingInstancesMap.set(instance.event_id, new Set())
    }
    existingInstancesMap.get(instance.event_id)?.add(instance.instance_date)
  })

  // Generate instances for each event
  const allNewInstances: EventInstance[] = []
  const results: { event_id: string; instances: EventInstance[] }[] = []

  for (const event of events) {
    let instances: EventInstance[] = []

    switch (event.recurrence_type) {
      case 'Once':
        if (!date) {
          throw new Error('Date is required for one-time events')
        }
        instances = [generateOnceInstance(event, date)]
        break

      case 'Weekly':
        if (!event.weekly_days || event.weekly_days.length === 0) {
          throw new Error('Weekly days are required for weekly events')
        }
        instances = generateWeeklyInstances(event, today, endDate)
        break

      case 'Monthly':
        if (!event.monthly_pattern || event.monthly_pattern.length === 0) {
          throw new Error('Monthly pattern is required for monthly events')
        }
        instances = generateMonthlyInstances(event, today, endDate)
        break

      default:
        throw new Error(`Invalid recurrence type for event ${event.event_id}`)
    }

    // Filter out existing instances for this event
    const existingDates = existingInstancesMap.get(event.event_id) || new Set()
    const newInstances = instances.filter(instance => !existingDates.has(instance.instance_date))

    if (newInstances.length > 0) {
      allNewInstances.push(...newInstances)
      results.push({
        event_id: event.event_id,
        instances: newInstances
      })
    }
  }

  if (allNewInstances.length === 0) {
    return { message: 'No new instances to create - all dates already have instances' }
  }

  // Insert all new instances in a single query
  const { error: insertError } = await supabaseClient
    .from('event_instances')
    .insert(allNewInstances)

  if (insertError) {
    throw new Error('Failed to insert event instances')
  }

  return {
    message: `Created ${allNewInstances.length} new instances across ${results.length} events`,
    results
  }
} 