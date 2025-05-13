-- Create a view for event ratings
CREATE VIEW event_ratings AS
SELECT 
    e.event_id,
    COALESCE(AVG(r.rating), 0) as average_rating,
    COUNT(r.rating) as rating_count
FROM events e
LEFT JOIN event_instances i ON e.event_id = i.event_id
LEFT JOIN instance_ratings r ON i.instance_id = r.instance_id
GROUP BY e.event_id;
