import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.7'

// Initialize Supabase client
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const supabase = createClient(supabaseUrl, supabaseServiceKey)

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
    const { payment_intent_id, amount, course_id, currency  } = body
    console.log('course_id', course_id)

    // Validate required fields
    if (!payment_intent_id || typeof payment_intent_id !== 'string') {
      return new Response(JSON.stringify({ error: 'payment_intent_id is required and must be a string' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    if (!amount || typeof amount !== 'number') {
      return new Response(JSON.stringify({ error: 'amount is required and must be a number' }), {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // Get user_id from the function environment (JWT token)
    const authHeader = req.headers.get('authorization')
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ error: 'Authorization header required' }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(JSON.stringify({ error: 'Invalid or expired token' }), {
        status: 401,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // Insert payment record into payments table
    const { data: paymentData, error: insertError } = await supabase
      .from('payments')
      .insert({
        stripe_id: payment_intent_id,
        amount: amount,
        user_id: user.id,
        currency: currency
      })
      .select()
      .single()

    if (insertError) {
      console.error('Payment insertion error:', insertError)
      return new Response(JSON.stringify({ 
        error: 'Failed to insert payment record',
        details: insertError.message 
      }), {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      });
    }

    // Return success response
    return new Response(JSON.stringify({
      success: true,
      payment: paymentData,
      message: 'Payment confirmed successfully'
    }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    });

  } catch (error: unknown) {
    console.error('Payment confirmation error:', error);
    
    const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
    
    return new Response(JSON.stringify({ 
      error: 'Failed to confirm payment',
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