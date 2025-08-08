import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno'

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

  // Only allow POST requests
  if (req.method !== 'POST') {
    return new Response('Method not allowed', {
      status: 405,
      headers: {
        'Content-Type': 'text/plain',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }

  try {
    // Parse request body
    const body = await req.json()
    const { amount, currency = 'usd', payment_method_types = ['card'], metadata = {}, stripe_account_id, production } = body

    let stripeSecretKey;
    // Initialize Stripe with your secret key
    if (production == true) {
      stripeSecretKey = Deno.env.get('STRIPE_SECRET_PROD_KEY');
    } else {
      stripeSecretKey = Deno.env.get('STRIPE_SECRET_TEST_KEY');
    }

    const stripe = new Stripe(stripeSecretKey, {
      apiVersion: '2024-12-18.acacia',
    })

    // Validate required fields
    if (!amount || typeof amount !== 'number') {
      return new Response(JSON.stringify({ error: 'Amount is required and must be a number' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // Validate amount (minimum $0.50)
    if (amount < 50) {
      return new Response(JSON.stringify({ error: 'Amount must be at least $0.50 (50 cents)' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Ensure amount is an integer (cents)
      currency: currency,
      payment_method_types: payment_method_types,
      metadata: {
        ...metadata,
        source: 'bachata_course',
        created_at: new Date().toISOString(),
      },
    }, {
      stripeAccount: stripe_account_id,
    });



    // Return the client secret
    return new Response(JSON.stringify({
      client_secret: paymentIntent.client_secret,
      payment_intent_id: paymentIntent.id,
      amount: paymentIntent.amount,
      currency: paymentIntent.currency,
    }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    });

  } catch (error: unknown) {
    console.error('Payment intent creation error:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
    
    return new Response(JSON.stringify({ 
      error: 'Failed to create payment intent',
      details: errorMessage 
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    });
  }
}) 