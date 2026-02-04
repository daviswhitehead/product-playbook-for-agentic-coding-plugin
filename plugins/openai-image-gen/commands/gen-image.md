---
name: gen-image
description: Generate images using OpenAI's image generation API
argument-hint: "<prompt> [--size 1024x1024|1792x1024|1024x1792] [--model gpt-image-1|dall-e-3] [--quality auto|hd] [--out filename.png]"
---

# Generate Image

Generate images using OpenAI's image generation API directly from Claude Code.

## Prerequisites

1. **OPENAI_API_KEY** must be set in your environment
2. **openai** npm package must be installed in your project
3. **tsx** must be available (npx will handle this)

## Setup (First Time Only)

If you haven't set up the script yet:

```bash
# Install openai package at project root
npm install openai --save

# Ensure OPENAI_API_KEY is set
export OPENAI_API_KEY=your-key-here
# Or add to .zshrc/.bashrc for persistence
```

## Usage

Run the image generation script with the user's prompt:

```bash
npx tsx scripts/gen-image.ts "<prompt>" [options]
```

### Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--size` | 1024x1024, 1792x1024, 1024x1792 | 1024x1024 | Image dimensions |
| `--model` | gpt-image-1, dall-e-3, dall-e-2 | gpt-image-1 | AI model to use |
| `--quality` | auto, low, medium, high, hd | auto | Image quality |
| `--out` | filename.png | timestamp.png | Output filename |

### Examples

```bash
# Basic logo generation
npx tsx scripts/gen-image.ts "Minimalist chef hat logo, flat vector style, black on white"

# Wide hero image
npx tsx scripts/gen-image.ts "Hero illustration for cooking app" --size 1792x1024

# High quality with custom name
npx tsx scripts/gen-image.ts "Premium food photography style pasta dish" --quality hd --out hero-pasta.png

# Using DALL-E 3 model
npx tsx scripts/gen-image.ts "Photorealistic kitchen scene" --model dall-e-3
```

## Output

Images are saved to `assets/generated/` directory:
- `<timestamp>.png` or `<custom-name>.png` - The generated image
- `<timestamp>.json` or `<custom-name>.json` - Metadata (prompt, settings, timestamp)

## Prompt Tips for Different Use Cases

### Logo Design
- "Minimalist logo mark: [subject], flat vector style, [colors], no text"
- "Hand-drawn logo: [subject], expressive lines, [style], simple design"
- "Negative space logo: [concept], optical illusion, two-tone"

### Marketing/Hero Images
- "Hero illustration for [product type], [style], [mood], wide composition"
- "Ad creative: [product/scene], [lighting], professional photography style"
- "Feature card illustration: [concept], modern flat design, [color palette]"

### Brand Exploration
- "Brand moodboard style: [concept], [aesthetic], [color direction]"
- "Logo variations: [core concept], 5 different interpretations"

## Workflow Integration

After generating images:
1. Review the output in `assets/generated/`
2. Iterate on prompts to refine the direction
3. For logos: final vectors should be recreated in Figma/Illustrator
4. For marketing: use directly or as reference for final assets

## Troubleshooting

### "OPENAI_API_KEY not set"
```bash
# Check if key is set
echo $OPENAI_API_KEY

# Set it temporarily
export OPENAI_API_KEY=sk-your-key

# Or add to shell config
echo 'export OPENAI_API_KEY=sk-your-key' >> ~/.zshrc
source ~/.zshrc
```

### "Cannot find module 'openai'"
```bash
npm install openai --save
```

### Rate limits or API errors
- Wait a moment and retry
- Check your OpenAI account for rate limit status
- Try a simpler prompt

## Notes

- gpt-image-1 is the latest model with best instruction following
- Generated images are raster (PNG) - for final logos, recreate as vectors
- Images are gitignored by default in `assets/generated/`
- Metadata JSON files preserve your prompts for iteration
