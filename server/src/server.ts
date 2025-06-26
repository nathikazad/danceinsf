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

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    return console.log(`[server]: Server is running on ${PORT}`);
});