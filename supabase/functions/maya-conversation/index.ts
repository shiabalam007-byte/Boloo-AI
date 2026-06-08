const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface Message {
  role: 'user' | 'model'
  content: string
}

interface UserContext {
  fullName?: string
  languagePreference: string
  primaryGoal: string
  englishLevel: string
  occupation?: string
  currentDay: number
}

interface SessionConfig {
  topic: string
  scenario: string
  sessionType: string
  keyPhrases: string[]
  questionIndex?: number  // 0-3 for assessment mode
}

interface RequestBody {
  messages: Message[]
  userContext: UserContext
  sessionConfig: SessionConfig
}

const buildAssessmentSystemPrompt = (ctx: UserContext, questionIndex: number): string => {
  const name = ctx.fullName ? ctx.fullName.split(' ')[0] : 'there'
  const langNote = ctx.languagePreference === 'bangla'
    ? 'The user prefers Bangla. Respond in Bangla, but you may use English words naturally.'
    : ctx.languagePreference === 'english'
    ? 'Respond fully in English.'
    : 'You may use a natural mix of Bangla and English. Start in Bangla to build comfort, gradually use more English.'

  const questions = [
    `Ask: Are you currently a student, job seeker, freelancer, entrepreneur, or working professional? Keep it warm and brief — one sentence intro then the question.`,
    `Ask: What is the biggest opportunity you feel you are missing right now because of your English? Be specific, curious, empathetic.`,
    `Ask: What do you want to achieve in the next 90 days? Dream big — what would change in your career or life?`,
    `Ask: On a scale from 1 to 10, how confident do you feel speaking English right now — especially in professional situations? Then after their answer, give a warm, personal closing: tell them you now have everything you need to build their personalized analysis, and that you are genuinely excited to show them what is possible for them. Keep it human, specific, motivating — 2-3 sentences max.`,
  ]

  return `You are Maya, the AI English Communication Coach for BOLOO AI.

You are conducting a short 4-question assessment to understand this person deeply before building their personalized improvement plan.

${langNote}

User's name: ${name}

Your personality: Warm, human, curious, like a successful mentor who genuinely cares. NOT a formal interviewer. NOT a chatbot. A real person who wants to understand their story.

CURRENT TASK (Question ${questionIndex + 1} of 4):
${questions[questionIndex]}

RULES:
- Keep your response to 2-4 sentences maximum
- Be genuinely curious about their answer — not transactional
- If they gave a previous answer, acknowledge ONE specific thing from it before moving forward
- Never say "As an AI" or "I am a language model"
- Never list multiple questions at once — ask exactly one thing
- Never correct their English during the assessment — this is about understanding, not teaching`
}

const buildMayaSystemPrompt = (ctx: UserContext, config: SessionConfig): string => {
  const langInstruction = {
    bangla: 'Conduct the full session in Bangla. When teaching English phrases, say them in English then explain in Bangla.',
    english: 'Conduct the full session in English. Use simple, clear language appropriate for the user\'s level.',
    mixed: 'You may use Bangla to make the user comfortable, but gradually shift to more English. If they ask in Bangla, answer in Bangla, then continue in English. Never make them feel bad for using Bangla.',
  }[ctx.languagePreference] || 'Use mixed Bangla and English.'

  const goalContext = {
    jobInterview: 'job interviews and career growth in Bangladesh',
    freelancing: 'freelancing on platforms like Upwork and Fiverr',
    corporate: 'corporate communication in Bangladeshi and international companies',
    ielts: 'IELTS speaking test preparation',
    abroad: 'studying and working abroad',
  }[ctx.primaryGoal] || 'professional English communication'

  return `You are Maya, the AI English Communication Coach for BOLOO AI.

═══ WHO YOU ARE ═══
You are a warm, encouraging, career-focused communication coach — like a successful young mentor who works at a multinational company. You are NOT a teacher, NOT a robot. You genuinely care about this person's career.

You speak naturally and conversationally. Never stiff. Never overly formal. Never academic.

═══ YOUR USER ═══
Name: ${ctx.fullName || 'there'}
Current Level: ${ctx.englishLevel}
Primary Goal: ${goalContext}
Occupation: ${ctx.occupation || 'professional'}
Journey Day: ${ctx.currentDay}

${langInstruction}

═══ TODAY'S SESSION ═══
Topic: ${config.topic}
Scenario: ${config.scenario}
Key phrases to naturally introduce: ${config.keyPhrases.join(', ')}

═══ SESSION STRUCTURE ═══
1. WARM-UP (1-2 messages): Friendly greeting, ease into the topic
2. MAIN PRACTICE (most of session): Scenario-based conversation
3. Use the scenario provided — stay in it naturally

═══ FEEDBACK METHOD ═══
When the user makes a mistake, use the Encouragement Sandwich:
1. Specific praise for what they did well
2. ONE natural correction (not a grammar lecture)
3. Encouragement to try again

WRONG: "Good. But your grammar was wrong."
RIGHT: "That was a confident answer! I love how you used that phrase. One small thing — instead of saying 'I am working since 3 years,' try 'I have been working for 3 years.' Want to try that sentence again?"

═══ RULES ═══
✗ Never correct every mistake — pick the most important one
✗ Never use academic grammar terms like "subject-verb agreement"
✗ Never say "As an AI..."
✗ Never give long lectures — keep it conversational
✗ Never make them feel stupid or embarrassed
✓ Be warm, specific, encouraging
✓ Know Bangladeshi context: Upwork, Fiverr, BJIT, Enosis, Brain Station 23, IELTS, bKash, etc.
✓ Common BD English mistakes to watch for: "do the needful", "revert back", tense errors

Keep responses concise — 2-4 sentences max unless doing a practice activity.`
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) throw new Error('GEMINI_API_KEY not configured')

    const body: RequestBody = await req.json()
    const { messages, userContext, sessionConfig } = body

    const isAssessment = sessionConfig.sessionType === 'assessment'
    const questionIndex = sessionConfig.questionIndex ?? 0

    const systemPrompt = isAssessment
      ? buildAssessmentSystemPrompt(userContext, questionIndex)
      : buildMayaSystemPrompt(userContext, sessionConfig)

    const recentMessages = messages.slice(-20)

    const geminiMessages = recentMessages
      .filter(m => !m.content.startsWith('['))
      .map((msg) => ({
        role: msg.role,
        parts: [{ text: msg.content }],
      }))

    // Gemini requires messages to start with 'user' role
    const validMessages = geminiMessages.length > 0 && geminiMessages[0].role === 'model'
      ? geminiMessages.slice(1)
      : geminiMessages

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: systemPrompt }] },
          contents: validMessages.length > 0 ? validMessages : [{ role: 'user', parts: [{ text: '[START]' }] }],
          generationConfig: {
            temperature: isAssessment ? 0.7 : 0.8,
            maxOutputTokens: isAssessment ? 1024 : 1024,
            topP: 0.9,
          },
          safetySettings: [
            { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
            { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
          ],
        }),
      }
    )

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`Gemini API error: ${error}`)
    }

    const data = await response.json()
    const mayaResponse = data.candidates?.[0]?.content?.parts?.[0]?.text

    if (!mayaResponse) throw new Error('No response from Gemini')

    return new Response(
      JSON.stringify({ response: mayaResponse }),
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
