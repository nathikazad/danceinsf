CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    
    -- Event type and category
    event_type TEXT[], -- 'Social' or 'Class'
    event_category TEXT[], -- 'Bachata' or 'Salsa'
    
    -- Recurrence information
    recurrence_type VARCHAR(20) NOT NULL, -- 'Once', 'Weekly', 'Monthly'
    recurrence_rule TEXT, -- Detailed rule for weekly/monthly patterns
    weekly_days TEXT[], -- For weekly: 'M,W,F' or 'Sa,Su'
    monthly_pattern TEXT[], -- For monthly: '1st-M,3rd-W'
    
    -- Date range for recurring events
    start_date DATE NOT NULL,
    end_date DATE, -- NULL for indefinite recurring events
    
    -- DEFAULT values for all instances
    default_description TEXT,
    default_start_time TIME NOT NULL,
    default_end_time TIME NOT NULL,
    default_cost DECIMAL(10,2),
    default_venue_name VARCHAR(255),
    default_city VARCHAR(100),
    default_google_maps_link TEXT,
    default_ticket_link TEXT,
    
    -- Common information
    organizer_name VARCHAR(255),
    organizer_phone VARCHAR(50),
    is_organizer BOOLEAN DEFAULT TRUE,

    -- Specific information for this event
    is_archived BOOLEAN DEFAULT FALSE,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_instances (
    instance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(event_id) ON DELETE CASCADE,
    
    -- Instance date (always required)
    instance_date DATE NOT NULL,
    
    -- OVERRIDE fields - NULL means use default from events table
    description TEXT, -- NULL = use default_description
    start_time TIME, -- NULL = use default_start_time
    end_time TIME, -- NULL = use default_end_time
    cost DECIMAL(10,2), -- NULL = use default_cost
    venue_name VARCHAR(255), -- NULL = use default_venue_name
    city VARCHAR(100), -- NULL = use default_city
    google_maps_link TEXT, -- NULL = use default_google_maps_link
    ticket_link TEXT, -- NULL = use default_ticket_link
    flyer_url TEXT, -- Instance-specific flyer
    
    -- Instance-specific fields
    special_notes TEXT, -- For special announcements
    is_cancelled BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(event_id, instance_date)
);

-- Create ratings table
CREATE TABLE instance_ratings (
    rating_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instance_id UUID REFERENCES event_instances(instance_id) ON DELETE CASCADE,
    user_id UUID,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);