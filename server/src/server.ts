import express, { Express, Request, Response, NextFunction } from 'express';
import { createServer } from 'http';
import { WebSocketServer, WebSocket } from 'ws';
import { createClient } from '@supabase/supabase-js';

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
    const videoLinksData = {
        intro: {
            title: "Intro Videos",
            videos: [
                {
                    playbackId: "6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00",
                    title: "Paso 1",
                    signed: false
                },
                {
                    playbackId: "9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM",
                    title: "Paso 2",
                    signed: false
                },
                {
                    playbackId: "SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00",
                    title: "Paso 3",
                    signed: false
                },
                {
                    playbackId: "1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8",
                    title: "Paso 4",
                    signed: false
                },
                {
                    playbackId: "PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE",
                    title: "Paso 5",
                    signed: false
                }
            ]
        },
        pasoUno: {
            title: "Paso Uno",
            videos: [
                {
                    playbackId: "AQ55vZPsJJnzWziqMmrufpoGyRr5WOL8RGI1PgAGphY",
                    title: "Musica",
                    signed: false
                },
                {
                    playbackId: "ZPnuFoZGQ01EFRuJwhq6qjWUdIcXxi00015i101aXWQluW8",
                    title: "Cuentas",
                    signed: false
                },
                {
                    playbackId: "74y1BX00aRR0201dLx0039m2Qm0253zQDjm3x9bc4RTv02kIM",
                    title: "Chicos",
                    signed: false
                },
                {
                    playbackId: "qq02MXs3kWmcyPS9P7DMgxZa4O6sP01h00le3z5oi5hz00g",
                    title: "Chicas",
                    signed: false
                }
            ]
        },
        pasoDos: {
            title: "Paso Dos",
            videos: [
                {
                    playbackId: "Qu86eMOGBCXYaPlmGLFoM6AEbmJ3Ia27BNjV99rtzmQ",
                    title: "Musica",
                    signed: true
                },
                {
                    playbackId: "35Lw4d3vY01bBPY9ZAu8uhLxs3kDLvAI6RlqzjPbMWps",
                    title: "Cuentas",
                    signed: true
                },
                {
                    playbackId: "01IyXQuljRPd3kwi6e2O93aBl1IE15qRkA6SbqRmzJy4",
                    title: "Chicos",
                    signed: true
                },
                {
                    playbackId: "mhWPMk9g02TzBcAqAMXgqbpmTJ2uDx7mVD0101ZEpP3tv8",
                    title: "Chicas",
                    signed: true
                }
            ]
        },
        pasoTres: {
            title: "Paso Tres",
            videos: [
                {
                    playbackId: "wD6vFBH6Zxt4tqsuuPPVozvraS00Mc99DEW412yqtELA",
                    title: "Musica",
                    signed: true
                },
                {
                    playbackId: "sI500X6a4VeAhjRe7LfTfDSz3WXPq9i5pwqtNL2XkkhA",
                    title: "Chicas",
                    signed: true
                }
            ]
        }
    };

    res.json(videoLinksData);
});

app.get('/ping', (req, res) => {
    res.send('pong');
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    return console.log(`[server]: Server is running on ${PORT}`);
});