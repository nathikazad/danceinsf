-- Insert one-time events
INSERT INTO events (
    name, event_type, event_category, recurrence_type, recurrence_rule,
    start_date, end_date, default_description, default_start_time, default_end_time,
    default_cost, default_venue_name, default_city, default_google_maps_link,
    organizer_name, organizer_phone
) VALUES
(
    'Summer Salsa Festival 2024',
    ARRAY['Social'],
    ARRAY['Salsa'],
    'Once',
    NULL,
    '2024-07-15',
    '2024-07-15',
    'Join us for the biggest salsa festival of the summer! Live bands, workshops, and social dancing all day.',
    '14:00:00',
    '23:00:00',
    45.00,
    'Grand Ballroom',
    'San Francisco',
    'https://maps.google.com/?q=Grand+Ballroom+SF',
    'SF Dance Events',
    '415-555-0123'
),
(
    'Bachata Masterclass with Juan',
    ARRAY['Class'],
    ARRAY['Bachata'],
    'Once',
    NULL,
    '2024-06-01',
    '2024-06-01',
    'Special masterclass with international bachata instructor Juan',
    '19:00:00',
    '21:00:00',
    35.00,
    'Dance Studio SF',
    'San Francisco',
    'https://maps.google.com/?q=Dance+Studio+SF',
    'SF Dance Academy',
    '415-555-0124'
);

-- Insert weekly recurring events
INSERT INTO events (
    name, event_type, event_category, recurrence_type, recurrence_rule,
    weekly_days, start_date, end_date, default_description, default_start_time,
    default_end_time, default_cost, default_venue_name, default_city,
    default_google_maps_link, organizer_name, organizer_phone
) VALUES
(
    'Monday Night Salsa Social',
    ARRAY['Social'],
    ARRAY['Salsa'],
    'Weekly',
    'Every Monday',
    ARRAY['M'],
    '2024-05-13',
    '2024-12-31',
    'Weekly salsa social with DJ playing the best salsa music',
    '20:00:00',
    '23:00:00',
    15.00,
    'Club Salsa',
    'San Francisco',
    'https://maps.google.com/?q=Club+Salsa+SF',
    'SF Dance Events',
    '415-555-0123'
),
(
    'Wednesday Bachata Classes',
    ARRAY['Class'],
    ARRAY['Bachata'],
    'Weekly',
    'Every Wednesday',
    ARRAY['W'],
    '2024-05-15',
    '2024-12-31',
    'Progressive bachata classes for all levels',
    '19:00:00',
    '21:00:00',
    20.00,
    'Dance Studio SF',
    'San Francisco',
    'https://maps.google.com/?q=Dance+Studio+SF',
    'SF Dance Academy',
    '415-555-0124'
);

-- Insert monthly recurring events
INSERT INTO events (
    name, event_type, event_category, recurrence_type, recurrence_rule,
    monthly_pattern, start_date, end_date, default_description, default_start_time,
    default_end_time, default_cost, default_venue_name, default_city,
    default_google_maps_link, organizer_name, organizer_phone
) VALUES
(
    'First Friday Salsa Night',
    ARRAY['Social'],
    ARRAY['Salsa'],
    'Monthly',
    'First Friday of every month',
    ARRAY['1st-F'],
    '2024-06-07',
    '2024-12-31',
    'Special salsa night with live band on the first Friday of every month',
    '21:00:00',
    '02:00:00',
    25.00,
    'Grand Ballroom',
    'San Francisco',
    'https://maps.google.com/?q=Grand+Ballroom+SF',
    'SF Dance Events',
    '415-555-0123'
);

-- Insert event instances for one-time events
INSERT INTO event_instances (
    event_id, instance_date, description, start_time, end_time,
    cost, venue_name, city, google_maps_link, ticket_link
) 
SELECT 
    event_id,
    start_date,
    default_description,
    default_start_time,
    default_end_time,
    default_cost,
    default_venue_name,
    default_city,
    default_google_maps_link,
    'https://tickets.example.com/' || event_id
FROM events 
WHERE recurrence_type = 'Once';

-- Insert event instances for weekly events (next 3 months)
WITH RECURSIVE dates AS (
    SELECT 
        e.event_id,
        e.start_date::date as instance_date,
        e.weekly_days,
        e.default_description,
        e.default_start_time,
        e.default_end_time,
        e.default_cost,
        e.default_venue_name,
        e.default_city,
        e.default_google_maps_link
    FROM events e
    WHERE e.recurrence_type = 'Weekly'
    UNION ALL
    SELECT 
        d.event_id,
        (d.instance_date + INTERVAL '1 day')::date,
        d.weekly_days,
        d.default_description,
        d.default_start_time,
        d.default_end_time,
        d.default_cost,
        d.default_venue_name,
        d.default_city,
        d.default_google_maps_link
    FROM dates d
    JOIN events e ON e.event_id = d.event_id
    WHERE d.instance_date < LEAST(e.end_date, CURRENT_DATE + INTERVAL '3 months')
)
INSERT INTO event_instances (
    event_id, instance_date, description, start_time, end_time,
    cost, venue_name, city, google_maps_link, ticket_link
)
SELECT 
    event_id,
    instance_date,
    default_description,
    default_start_time,
    default_end_time,
    default_cost,
    default_venue_name,
    default_city,
    default_google_maps_link,
    'https://tickets.example.com/' || event_id || '/' || instance_date
FROM dates
WHERE EXTRACT(DOW FROM instance_date) = 
    CASE 
        WHEN 'M' = ANY(weekly_days) THEN 1
        WHEN 'W' = ANY(weekly_days) THEN 3
        WHEN 'F' = ANY(weekly_days) THEN 5
        WHEN 'Sa' = ANY(weekly_days) THEN 6
        WHEN 'Su' = ANY(weekly_days) THEN 0
    END;

-- Insert event instances for monthly events (next 6 months)
WITH RECURSIVE months AS (
    SELECT 
        e.event_id,
        e.start_date::date as instance_date,
        e.monthly_pattern,
        e.default_description,
        e.default_start_time,
        e.default_end_time,
        e.default_cost,
        e.default_venue_name,
        e.default_city,
        e.default_google_maps_link
    FROM events e
    WHERE e.recurrence_type = 'Monthly'
    UNION ALL
    SELECT 
        m.event_id,
        (m.instance_date + INTERVAL '1 month')::date,
        m.monthly_pattern,
        m.default_description,
        m.default_start_time,
        m.default_end_time,
        m.default_cost,
        m.default_venue_name,
        m.default_city,
        m.default_google_maps_link
    FROM months m
    JOIN events e ON e.event_id = m.event_id
    WHERE m.instance_date < LEAST(e.end_date, CURRENT_DATE + INTERVAL '6 months')
)
INSERT INTO event_instances (
    event_id, instance_date, description, start_time, end_time,
    cost, venue_name, city, google_maps_link, ticket_link
)
SELECT 
    event_id,
    instance_date,
    default_description,
    default_start_time,
    default_end_time,
    default_cost,
    default_venue_name,
    default_city,
    default_google_maps_link,
    'https://tickets.example.com/' || event_id || '/' || instance_date
FROM months;
