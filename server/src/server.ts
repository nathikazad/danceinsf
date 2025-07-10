import express, { Express, Request, Response, NextFunction } from 'express';
import { createServer } from 'http';
import { WebSocketServer, WebSocket } from 'ws';
import { createClient } from '@supabase/supabase-js';
import { videoLinksWithTokens } from './jwt';

const app: Express = express();

const server = createServer(app);

// Create WebSocket server
const wss = new WebSocketServer({ server });

// Set up WebSocket connection handling

app.use(express.json());

// Add CORS middleware
app.use((req: Request, res: Response, next: NextFunction) => {
    // Allow specific origins for production, or all for development
    const allowedOrigins = [
        'https://wheredothey.dance',
        'http://dondebailan.com',
        'https://dancesf.herokuapp.com',
        'http://localhost:3000',
        'http://localhost:8080',
        'http://localhost:5000',
        'http://localhost:57555',

    ];
    
    const origin = req.headers.origin;
    if (origin && allowedOrigins.includes(origin)) {
        res.header('Access-Control-Allow-Origin', origin);
    } else {
        console.log('origin', origin);
        res.header('Access-Control-Allow-Origin', '*');
    }
    
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    res.header('Access-Control-Allow-Credentials', 'true');
    
    if (req.method === 'OPTIONS') {
        res.sendStatus(200);
    } else {
        next();
    }
});

// List of reserved paths (add any other endpoints you want to exclude from redirect)
const reserved = [
    'parseUserRequestFromAudio',
    'parseUserRequestFromText',
    'updateLocation',
    'uploadSleep',
    'createLocation',
    'hasuraJWT',
    'deleteUser',
    'notifyParticipants',
    'video-links',
    'api',
];

// Catch-all redirect for short URLs
app.get('/:shortUrl', async (req: Request, res: Response, next: NextFunction) => {
    const supabaseUrl = 'https://swsvvoysafsqsgtvpnqg.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3c3Z2b3lzYWZzcXNndHZwbnFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5Mzk1NzgsImV4cCI6MjA2MjUxNTU3OH0.Z3J3KaWt3zd55GSx2fvAZBzd0WRYDWxFzL-eA4X0l54';
    const supabase = createClient(supabaseUrl, supabaseAnonKey);
    if (reserved.includes(req.params.shortUrl)) return next();

    const shortUrl = req.params.shortUrl;
    // Only redirect if it matches a 4-character alphanumeric code
    if (/^[A-Za-z0-9]{4}$/.test(shortUrl)) {
        try {
            // Query Supabase for event_instances with this short_url_prefix
            const { data, error } = await supabase
                .from('event_instances')
                .select('instance_id')
                .eq('short_url_prefix', shortUrl.toUpperCase())
                .single();
            if (error) {
                console.error('Supabase error:', error);
            }
            if (data && data.instance_id) {
                console.log(`redirecting to ${data.instance_id}`)
                return res.redirect(301, `https://wheredothey.dance/event/${data.instance_id}`);
            }
        } catch (e) {
            console.error('Supabase fetch error:', e);
        }
        // fallback to old redirect if not found
        return res.redirect(301, `https://wheredothey.dance/`);
    }
    // Otherwise, continue to 404 or other handlers
    return next();
});

app.get('/', async (req: Request, res: Response, next: NextFunction) => {
    return res.redirect(301, `https://wheredothey.dance/`);
});

app.get('/video-links', (req: Request, res: Response) => {
    res.json(videoLinksWithTokens());
});

app.get('/ping', (req, res) => {
    res.send('pong');
});

// Google Places API proxy endpoints
app.get('/api/places/autocomplete', async (req: Request, res: Response) => {
    // Set CORS headers specifically for this endpoint
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    
    try {
        const { input, location, radius, key } = req.query;
        
        if (!input || !key) {
            return res.status(400).json({ error: 'Missing required parameters: input and key' });
        }

        const url = new URL('https://maps.googleapis.com/maps/api/place/autocomplete/json');
        url.searchParams.set('input', input as string);
        if (location) url.searchParams.set('location', location as string);
        if (radius) url.searchParams.set('radius', radius as string);
        url.searchParams.set('key', key as string);

        const response = await fetch(url.toString());
        const data = await response.json();

        res.json(data);
    } catch (error) {
        console.error('Places autocomplete proxy error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/places/details', async (req: Request, res: Response) => {
    // Set CORS headers specifically for this endpoint
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    
    try {
        const { place_id, fields, key } = req.query;
        
        if (!place_id || !key) {
            return res.status(400).json({ error: 'Missing required parameters: place_id and key' });
        }

        const url = new URL('https://maps.googleapis.com/maps/api/place/details/json');
        url.searchParams.set('place_id', place_id as string);
        if (fields) url.searchParams.set('fields', fields as string);
        url.searchParams.set('key', key as string);

        const response = await fetch(url.toString());
        const data = await response.json();

        res.json(data);
    } catch (error) {
        console.error('Places details proxy error:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Handle OPTIONS requests for CORS preflight
app.options('/api/places/autocomplete', (req: Request, res: Response) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    res.sendStatus(200);
});

app.options('/api/places/details', (req: Request, res: Response) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    return console.log(`[server]: Server is running on ${PORT}`);
});