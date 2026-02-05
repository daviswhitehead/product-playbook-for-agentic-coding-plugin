# Alternative Image Generation Providers

This plugin focuses on OpenAI, but there are many other excellent providers for different use cases. This reference helps you choose the right tool for specific needs.

> **Source**: This comparison is based on [shipdeckai/claude-skills/image-gen](https://github.com/shipdeckai/claude-skills/tree/main/plugins/image-gen), which implements multi-provider support.

## Provider Comparison

| Provider | Best For | Generate | Edit | Max Size | Speed |
|----------|----------|----------|------|----------|-------|
| **OpenAI** | Versatile, creative | ✅ | ✅ | 1792x1792 | Fast |
| Stability AI | Photorealism | ✅ | ✅ | 2048x2048 | Fast |
| BFL (FLUX) | Ultra-high quality | ✅ | ✅ | 2048x2048 | Moderate |
| Ideogram | Text rendering, logos | ✅ | ✅ | 2048x2048 | Fast |
| FAL | Fast iterations | ✅ | ❌ | 2048x2048 | Very Fast |
| Gemini | Multimodal context | ✅ | ✅ | 2048x2048 | Moderate |
| Replicate | FLUX models | ✅ | ❌ | 2048x2048 | Fast |
| Clipdrop | Background removal | ❌ | ✅ | N/A | Fast |
| Leonardo | Artistic, cinematic | ✅ | ❌ | 1024x1024 | Moderate |
| Recraft | Perfect text, vectors | ✅ | ❌ | 2048x2048 | Fast |

## When to Consider Other Providers

### Text/Typography Heavy (Logos, Signage)
**Best**: Ideogram, Recraft
- OpenAI's gpt-image-1 is good, but Ideogram and Recraft specialize in text rendering
- Recraft is #1 globally ranked for text accuracy

### Photorealism
**Best**: BFL (FLUX), Stability AI
- BFL FLUX produces state-of-the-art photorealistic images
- Stability AI offers fine parameter control

### Fast Iterations/Prototyping
**Best**: FAL
- Sub-second generation for quick exploration
- Great for rapid iteration cycles

### Image Editing
**Best**: Clipdrop (backgrounds), OpenAI, Stability
- Clipdrop specializes in background removal/replacement
- OpenAI and Stability offer general editing

### Artistic/Fantasy/Game Assets
**Best**: Leonardo
- Specializes in cinematic and fantasy art
- Strong for game asset generation

## API Key Sources

If you want to extend beyond OpenAI:

| Provider | Get API Key |
|----------|-------------|
| OpenAI | https://platform.openai.com/api-keys |
| Stability AI | https://platform.stability.ai/account/keys |
| BFL | https://api.bfl.ml/ |
| Ideogram | https://ideogram.ai/api |
| FAL | https://fal.ai/dashboard/keys |
| Gemini | https://aistudio.google.com/apikey |
| Replicate | https://replicate.com/account/api-tokens |
| Clipdrop | https://clipdrop.co/apis |
| Leonardo | https://app.leonardo.ai/settings (subscription required) |
| Recraft | https://www.recraft.ai/ (subscription required) |

## Multi-Provider Implementation

For multi-provider support with automatic fallback, see:
- **[shipdeckai/claude-skills/image-gen](https://github.com/shipdeckai/claude-skills/tree/main/plugins/image-gen)**

Their implementation includes:
- Intelligent provider selection based on prompt content
- Automatic fallback chain when providers fail
- Unified CLI for all providers
- Image editing support

## OpenAI Model Details

Since this plugin focuses on OpenAI, here's detailed model info:

### gpt-image-1 (Default, Recommended)
- Superior instruction following
- Good text rendering
- Fast generation
- Sizes: 1024x1024, 1792x1024, 1024x1792

### DALL-E 3
- High quality output
- Strong creative interpretation
- Sizes: 1024x1024, 1792x1024, 1024x1792
- Supports HD quality mode

### DALL-E 2
- Faster, simpler
- Good for basic needs
- Size: 1024x1024 only
- Lower cost per image

## Recommendation

**Start with this plugin** (OpenAI-only) for:
- Quick setup and simple workflows
- General-purpose image generation
- When you already have an OpenAI API key

**Consider multi-provider** (shipdeckai) for:
- Production systems needing reliability
- Specific use cases (text-heavy logos → Ideogram)
- Image editing workflows
- Maximum quality requirements
