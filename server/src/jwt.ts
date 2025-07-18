import jwt from 'jsonwebtoken';

const _signingKeyId = '4UHhB302P5OtfwKGSJly02J8Zhwi3aB1e7dfMaq00DeQlI'; // To be filled by user
const _base64PrivateKey = 'LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBdlFIT1pUMXpFaEV0SUErVERQVEhaUWVTc1VFNks1NUYyU0FPR2s4ZUFXRzV0cUs3CnFiOEhvVUs1NDZwQlFEZjBNYTBJTVRwZ1ZFWnJ3VWlSTWJKdE9McWpQVEdZUXd5QlZGd3ZqY3pRQWdaalBMWWEKVTdrRThoczdGVWdyUnFvUzRpdVdIWnZzdzFiOVQzaTdXSWU2N2wxZGh0MEsvR3A1dHlnTDB0MU9yUlF6USs2bwpWbldTOGhoRHdDUEcyWUFwdThKTVpmMVNjU2hVSHpIU1JjcDFBUlNGcVVMVFlxSWRtVHVWbzJJZUR3M3dmUVhkCi93SzQ4b2xpNVFjQ3NzelZMQU5rQ05RMWVtYVNMM0Y4UlpFZkdITmVuMHJNakVkWFR3amJPVHVqZS9vc2g3MFMKRmR5SnVlY3luWFpWVW9meXk2MmY2elBNOE9WQVRNR3EwWFdJRndJREFRQUJBb0lCQUFYNEI2SkUydHh5M3hUegpIa3dReURkQVBQbGlFUFNOcnJFRHI4NVVPZml3aUdLUEtHbGM3TFhDc0xJb09mVk5qeEJUNFpLdkZabXp1NkFZCkFFQ0IzUUhSOWI1dlVZVlVpMiswUUVBMGUvYUVhSFU0dEZqT2hWY2hWYS8vWG5hQWY5RFZXdUZHZjZkUG1QZW8KaUJUQi9KSkloVFZHeDhaZTZuSEdwRkR5eDVMMFVYYXdubkJwTUdYR0tva1dhTUIxTFVWcUxFdXJZMkN6M0kzWgpvZXh4QU11dzl1amRZWWNJbFFtaDRVNkhVY3M3ajFLOXc5Z0w4andLd0ZuT2tHcGd2Mm5rcmxNOFYrdFNhZTVsCi9xeXRRR0cwM3BacU00Z2JuTkJuUk1HNmluNlJkUjBPTDRSdlhBRnBTUW9nQzlwYkpjR1dMMFRKZVFhNjUxcVAKTTcraHNVRUNnWUVBMnBvU1Y5SzgyeDdmdnNualNxRE5qdDAyV0pqSVRlUnJrYVY4S1ROdlBSVU9VeW93RG1obwpUL0xQM3VaSS9lbjN5bituUEUrcWFRSjV3WDhuR0t1YkF3SHIvRDdxSnRVd0FBMWI2ZDlkeHphc09PclMvWmFrCmdIMmt3RmhjdlYvMG1YT1RBUVlYWE4yYTJsVi9JM0ZMc0RNdmh1ZHNRd0xkNTBqR25YNGxpTGNDZ1lFQTNWZVkKZVhQazBTKzJwWFlkUzFhdVdid0Y2QnlTMmp4dW1KNzFlTktxRUNHU0xzNkhtL3Y4TWpuVWNsNkZPN056NjVIMApENVppb0ZhdmVVQzhqVmxqVXNQenJEM2FxTGxLM2J0WTJkbmNkcVVqVis0Q3VITmZCbEEvT2FMOCtESTFzRW41CmJTS0xtcStHOWNXZ0hta1crVkllbGFoeDEvN0c1T1Q5TXYxSzI2RUNnWUVBaFFJaUR4WEdtM3pabnZpd040UkkKRHBsQ3EvMnFRdHF0S04yTUFuV3RSWGsrVWhQbFVaN3RlVmZBYTF1ckpmUHFOV2dlbFcvVHZEa3BaRGE5enlENwpISVZhMVF4aTVHWHE0dDArQTd0SkVDR1FBTUhBeDFPVm5Dald5Y0g2QzdBSzRDT1dXcFVlT2Y4TWJiUi91MDBBClJLR2dWWEVTU21QQUtTMzZ5M0VwM1ZrQ2dZQVFNQXpWclJVcCsxeFhRNGttN21MMzZ4bGZmVjk4R0hsYUxoM3oKeFN4czI1ZXVWcXB5VFA2SHlkVHd2RnJ3SDlLMWdzb2ZyYmJ1MVFnbVRRYTlLN0ZvNXkzV0Jmd001T2hGeVNMWgpZK2FNd3MwUDdEZEV1Q05WK2Q1MTM2YXluREZ6QUNYK3hrMEJkaDdmc0tGaU4vdFhKcHRZQkthMnprcExpVGUvClYrajJvUUtCZ1FDY0N2dGZ5YXZaZUxmRUpJVHhDVVFUUlJSbjlDem9Zbk1Qa25vS0dZd3crWE5Xenh2SnN0TWUKMTdzRnlpYlVrSW9kS3lwY3pOOUgxMDR4alNTa0RqdStRaEsxelhKWFFoK2JkL090a0Z2RmVUMDQ2QndKSldZNQpCRDBjWXo0R1FtbHI3TE5ONy9SWmRJc1VXRFh0MldvNkZ6NEliYWh4T210eGlxTERFOXdHVHc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo='; // To be filled by user

/**
 * Generates a JWT token for Mux stream access
 * 
 * @param playbackId - The Mux playback ID for the stream
 * @param isThumbnail - Whether this token is for thumbnail access
 * @param expiresIn - Token expiration time in seconds (default: 1 hour)
 * @returns A signed JWT token string
 */
export function generateToken(
  playbackId: string,
  isThumbnail: boolean = false,
  expiresIn: number = 3600 // 1 hour default
): string {
  try {
    // Decode the base64 private key to get the PEM string
    const privateKeyBytes = Buffer.from(_base64PrivateKey, 'base64');
    const privateKey = privateKeyBytes.toString('utf8');

    // Create JWT payload
    const payload = {
      sub: playbackId,
      aud: isThumbnail ? 't' : 'v',
      exp: Math.floor(Date.now() / 1000) + expiresIn,
      kid: _signingKeyId,
    };

    // Sign with RS256 algorithm
    const token = jwt.sign(payload, privateKey, {
      algorithm: 'RS256',
      issuer: 'https://stream.mux.com',
    });

    return token;
  } catch (e) {
    throw new Error(`Failed to generate JWT token: ${e}`);
  }
}

const videoLinksData = [
    {
        title: "Intro Videos",
        videos: [
            {
                playbackId: "O5trriahYhJmamV1xEIHbiv01bpErvesx584SqO7bP8s",
                title: "Todo",
                signed: true
            },
            {
                playbackId: "AQ55vZPsJJnzWziqMmrufpoGyRr5WOL8RGI1PgAGphY",
                title: "Paso 1",
                signed: false
            },
            {
                playbackId: "Qu86eMOGBCXYaPlmGLFoM6AEbmJ3Ia27BNjV99rtzmQ",
                title: "Paso 2",
                signed: true
            },
            {
                playbackId: "wD6vFBH6Zxt4tqsuuPPVozvraS00Mc99DEW412yqtELA",
                title: "Paso 3",
                signed: true
            },
            {
                playbackId: "vFdGM02DUdZPPR8FZ1ta8NBteLlyM2ZKQ1Jx01OvbKnpU",
                title: "Paso 4",
                signed: true
            },
            {
                playbackId: "FL7KL5Km00kpcm901lFVTnCsEOxYf3sOxhp7mYkBqGm7o",
                title: "Paso 5",
                signed: true
            },
            {
                playbackId: "IbUSlYa7fVr702h4814awwkVKmU7zOGJ502W3UFeZaZEs",
                title: "Paso 6",
                signed: true
            }
        ]
    },
    {
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
    {
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
    {
        title: "Paso Tres",
        videos: [
            {
                playbackId: "wD6vFBH6Zxt4tqsuuPPVozvraS00Mc99DEW412yqtELA",
                title: "Musica",
                signed: true
            },
            {
                playbackId: "7yE02oLqKxyVVvGbWQr200ds7bCu8cRn2sdaPy601Bxlng",
                title: "Cuentas",
                signed: true
            },
            {
                playbackId: "LQcNDk7sJmxyCkNcTmbtmT4Xs2Ocz02GDuy8quXfg7CQ",
                title: "Chicos",
                signed: true
            },
            {
                playbackId: "sI500X6a4VeAhjRe7LfTfDSz3WXPq9i5pwqtNL2XkkhA",
                title: "Chicas",
                signed: true
            }
        ]
    },
    {
        title: "Paso Cuatro",
        videos: [
            {
                playbackId: "vFdGM02DUdZPPR8FZ1ta8NBteLlyM2ZKQ1Jx01OvbKnpU",
                title: "Musica",
                signed: true    
            },
            {
                playbackId: "Y02QDctg5WXYjLf601tpY8CC6AizdlJYEleSBXTHmpNyM",
                title: "Cuentas",
                signed: true
            },
            {
                playbackId: "RB01Giw3t701wOdBDwkUG02licseSRJjqCfHs9uYmQJL5g",
                title: "Chicos",
                signed: true
            },
            {   
                playbackId: "rixSiMvvtf022tAGFrqhQHhMEaiddKBaUDhg49dmlrfo",
                title: "Chicas",
                signed: true
            }
        ]
    },
    {
        title: "Paso Cinco",
        videos: [
            {
                playbackId: "FL7KL5Km00kpcm901lFVTnCsEOxYf3sOxhp7mYkBqGm7o",
                title: "Musica",
                signed: true
            },
            {
                playbackId: "j92Qsr00iL63eh4JqXIN00pclHGMaKOtS4Un4QEz31H24",
                title: "Cuentas",
                signed: true
            },
            {
                playbackId: "Qep2QNofIxAVLJrIbyiSCkmHsph4TyGIf6y7mgHRZtk",
                title: "Chicos",
                signed: true
            },
            {
                playbackId: "CxHHoqUYaNDmh01wt92OpU5P82XQGwDnkWOZD1GWAm9Q",
                title: "Chicas",
                signed: true
            }
        ]
    },
    {
        title: "Paso Seis",
        videos: [
            {
                playbackId: "IbUSlYa7fVr702h4814awwkVKmU7zOGJ502W3UFeZaZEs",
                title: "Musica",
                signed: true
            },
            {
                playbackId: "2aBSFVsCouGm5zABKv22kyjlUtarAKrVr00hN3NwLWJI",
                title: "Cuentas",
                signed: true
            },
            {
                playbackId: "qhkZwuw6pWchRa00IHhIk4A7dWW01nWCuGgId00uS79xts",
                title: "Chicos",
                signed: true
            },
            {
                playbackId: "zLM8lxN5yybJOCkEeO00v9AibYZWePhIELXwDVwQeQnM",
                title: "Chicas",
                signed: true
            }
        ]
    }
];

function generateStreamUrl(playbackId: string, signed: boolean) {
    if (signed) {
        const token = generateToken(playbackId, false, 3600);
        return `https://stream.mux.com/${playbackId}.m3u8?token=${token}`;
    } else {
        return `https://stream.mux.com/${playbackId}.m3u8`;
    }
}

function generateThumbnailUrl(playbackId: string, signed: boolean) {
    if (signed) {
        const token = generateToken(playbackId, true, 3600);
        return `https://image.mux.com/${playbackId}/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop&token=${token}`;
    } else {
        return `https://image.mux.com/${playbackId}/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop`;
    }
}

export function videoLinksWithTokens() {
    const result: any = {};
    
    for (const key in videoLinksData) {
        result[key] = {
            title: (videoLinksData as any)[key].title,
            videos: (videoLinksData as any)[key].videos.map((video: any) => {
                return {
                    ...video,
                    signed: true,
                    streamUrl: generateStreamUrl(video.playbackId, video.signed),
                    thumbnailUrl: generateThumbnailUrl(video.playbackId, video.signed)
                };
            })
        };
    }
    
    return result;
}
