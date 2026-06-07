import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ScoringRequest {
  conversationId: string
  transcript: string
  userLevel: string
  languagePreference: string
  topic: string
}

const scoringPrompt = `You are an English communication assessment expert for Bangladeshi learners.

Analyze the following conversation transcript and return a JSON score object.

Scoring rubrics:

CONFIDENCE SCORE (0-100):
90-100: Direct, assertive, no hedging
70-89: Mostly direct, minimal uncertainty
50-69: Some hedging, pauses on difficult topics  
30-49: Frequent hesitation, many filler phrases
0-29: Very limited, avoids direct answers

FLUENCY SCORE (0-100):
90-100: Natural flow, appropriate pace, minimal fillers
70-89: Good flow with occasional pauses
50-69: Noticeable hesitations, some fillers
30-49: Frequent pauses and fillers
0-29: Choppy, many long pauses

COMMUNICATION SCORE (0-100):
90-100: Clear message, professional vocabulary, structured responses
70-89: Generally clear with minor gaps
50-69: Message understood but could be clearer
30-49: Unclear communication in places
0-29: Difficult to understand main points

OVERALL SCORE: Average of the three scores.

Be encouraging but honest. Score for genuine improvement.

Return ONLY valid JSON with this exact structure:
{
  "confidence_score": number,
  "fluency_score": number,
  "communication_score": number,
  "overall_score": number,
  "strengths": ["specific strength 1", "specific strength 2"],
  "improvements": ["one specific improvement suggestion"],
  "maya_feedback": "warm 3-4 sentence personal feedback in the user's language preference"
}`

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const body: ScoringRequest = await req.json()

    const prompt = `${scoringPrompt}

Language preference: ${body.languagePreference}
User level: ${body.userLevel}
Topic: ${body.topic}

Transcript (user messages only):
${body.transcript}

Return the JSON score object now:`

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.3,
            maxOutputTokens: 600,
            responseMimeType: 'application/json',
          },
        }),
      }
    )

    const data = await response.json()
    const scoreText = data.candidates?.[0]?.content?.parts?.[0]?.text

    if (!scoreText) throw new Error('No score response')

    const scores = JSON.parse(scoreText)

    await supabase.from('conversations').update({
      confidence_score: scores.confidence_score,
      fluency_score: scores.fluency_score,
      communication_score: scores.communication_score,
      overall_score: scores.overall_score,
      maya_feedback: scores.maya_feedback,
    }).eq('id', body.conversationId)

    await supabase.from('score_history').insert({
      conversation_id: body.conversationId,
      user_id: (await supabase.from('conversations').select('user_id').eq('id', body.conversationId).single()).data?.user_id,
      confidence_score: scores.confidence_score,
      fluency_score: scores.fluency_score,
      communication_score: scores.communication_score,
      overall_score: scores.overall_score,
    })

    return new Response(
      JSON.stringify(scores),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
