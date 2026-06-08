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
  mode?: 'practice' | 'assessment'
  fullTranscript?: string  // assessment mode: full conversation including Maya's messages
}

const practiceScoringPrompt = `You are an English communication assessment expert for Bangladeshi learners.

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

const assessmentScoringPrompt = `You are Maya, the AI English Communication Coach for BOLOO AI.

You have just completed a 4-question assessment conversation with a new user. Analyze the full conversation transcript and return a deeply personalized assessment result.

SCORING GUIDELINES:

CONFIDENCE SCORE (0-100) — Based on HOW they expressed themselves:
- Sentence length, use of filler words, directness of answers
- Short fragmented answers = lower score. Detailed, specific answers = higher score.
- Scores must vary based on actual content. Do not default to 50-60.

COMMUNICATION SCORE (0-100) — Based on vocabulary and clarity:
- Vocabulary range, sentence structure, ability to express complex ideas
- Simple basic vocabulary = 30-50. Professional, nuanced vocabulary = 70-90.

DETECTED PROFILE — From their answers, infer:
- detected_goal: one of exactly: "jobInterview", "freelancing", "corporate", "ielts", "abroad"
  (if unclear, pick the closest match)
- detected_level: one of exactly: "beginner", "intermediate", "upperIntermediate"
  (use their self-reported confidence AND how they actually wrote)
- detected_occupation: their job/student status as a short string (e.g. "Software Developer", "Student", "Freelancer")

STRENGTHS — 2 specific, genuine strengths observed in their responses.
Make these feel personal, not generic. Reference something they actually said.

WEAKNESSES — 2 specific gaps that are holding them back.
Be honest but compassionate. These should feel real and addressable.

BIGGEST OPPORTUNITY — One specific opportunity statement tied to their stated goals.
Example: "Your Upwork goal is within reach — the only barrier between you and your first $500 client is the confidence to get on a video call."

RECOMMENDATION — One specific, motivating first action step.
This should feel like advice from a mentor who has studied their case, not a generic tip.

Return ONLY valid JSON with this exact structure:
{
  "confidence_score": number,
  "communication_score": number,
  "overall_score": number,
  "strengths": ["specific strength 1 referencing their actual answer", "specific strength 2"],
  "weaknesses": ["specific weakness 1", "specific weakness 2"],
  "biggest_opportunity": "one specific opportunity statement",
  "recommendation": "one specific first step",
  "detected_goal": "jobInterview|freelancing|corporate|ielts|abroad",
  "detected_level": "beginner|intermediate|upperIntermediate",
  "detected_occupation": "their occupation as a string"
}`

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const body: ScoringRequest = await req.json()

    const isAssessment = body.mode === 'assessment'

    const systemPrompt = isAssessment ? assessmentScoringPrompt : practiceScoringPrompt

    const transcriptContent = isAssessment
      ? `Full assessment conversation:\n${body.fullTranscript || body.transcript}`
      : `Language preference: ${body.languagePreference}\nUser level: ${body.userLevel}\nTopic: ${body.topic}\n\nTranscript (user messages only):\n${body.transcript}`

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: `${systemPrompt}\n\n${transcriptContent}\n\nReturn the JSON now:` }] }],
          generationConfig: {
            temperature: 0.3,
            maxOutputTokens: 800,
            responseMimeType: 'application/json',
          },
        }),
      }
    )

    const data = await response.json()
    const scoreText = data.candidates?.[0]?.content?.parts?.[0]?.text

    if (!scoreText) throw new Error('No score response')

    const scores = JSON.parse(scoreText)

    if (isAssessment) {
      // For assessment: store scores in conversation, do NOT create score_history entry
      await supabase.from('conversations').update({
        confidence_score: scores.confidence_score,
        communication_score: scores.communication_score,
        overall_score: scores.overall_score,
        maya_feedback: scores.recommendation,
      }).eq('id', body.conversationId)
    } else {
      // Regular practice session: full scoring + score history
      await supabase.from('conversations').update({
        confidence_score: scores.confidence_score,
        fluency_score: scores.fluency_score,
        communication_score: scores.communication_score,
        overall_score: scores.overall_score,
        maya_feedback: scores.maya_feedback,
      }).eq('id', body.conversationId)

      const { data: convo } = await supabase
        .from('conversations')
        .select('user_id')
        .eq('id', body.conversationId)
        .single()

      if (convo?.user_id) {
        await supabase.from('score_history').insert({
          conversation_id: body.conversationId,
          user_id: convo.user_id,
          confidence_score: scores.confidence_score,
          fluency_score: scores.fluency_score,
          communication_score: scores.communication_score,
          overall_score: scores.overall_score,
        })
      }
    }

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
