import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Rate limiting: 30 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // 30 requests per window
  message: { error: 'Too many requests. Please try again in 15 minutes.' }
});

app.use('/api/', limiter);

// Health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    app: 'Genuity AI Backend',
    version: '1.0.0'
  });
});

// Chat endpoint (proxy to OpenAI)
app.post('/api/chat', async (req, res) => {
  try {
    const { messages } = req.body;

    // Validate input
    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: 'Invalid request: messages array required' });
    }

    // Get API key from environment
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      console.error('❌ OPENAI_API_KEY not set!');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    // Call OpenAI
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: messages,
        temperature: 0.7,
        max_tokens: 150
      })
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('OpenAI API Error:', errorData);
      return res.status(response.status).json({ 
        error: 'OpenAI API error',
        details: errorData 
      });
    }

    const data = await response.json();
    
    // Return just the AI response
    res.json({
      message: data.choices[0]?.message?.content || 'No response',
      usage: data.usage // Optional: track token usage
    });

  } catch (error) {
    console.error('Server error:', error);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ Genuity AI Backend running on port ${PORT}`);
  console.log(`🔒 API key configured: ${process.env.OPENAI_API_KEY ? 'YES' : 'NO'}`);
});

