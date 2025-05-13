-- Create a function to get ratings for specific events
CREATE OR REPLACE FUNCTION get_event_ratings(event_ids UUID[])
RETURNS TABLE (
    event_id UUID,
    average_rating DECIMAL,
    rating_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.event_id,
        COALESCE(AVG(r.rating), 0) as average_rating,
        COUNT(r.rating) as rating_count
    FROM events e
    LEFT JOIN event_instances i ON e.event_id = i.event_id
    LEFT JOIN instance_ratings r ON i.instance_id = r.instance_id
    WHERE e.event_id = ANY(event_ids)
    GROUP BY e.event_id;
END;
$$ LANGUAGE plpgsql;