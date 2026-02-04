# OpenAI Image Generation Plugin

Generate images using OpenAI's image generation API directly from Claude Code. Create logos, illustrations, marketing assets, and more with simple text prompts.

## Features

- **Multiple Models**: Support for gpt-image-1 (recommended), DALL-E 3, and DALL-E 2
- **Flexible Sizes**: Square (1024x1024), landscape (1792x1024), portrait (1024x1792)
- **Quality Control**: Auto, low, medium, high, and HD quality options
- **Metadata Tracking**: Each image saves alongside a JSON with prompt and settings
- **Simple CLI**: Easy-to-use command line interface

## Installation

### 1. Install the Plugin

Add this plugin to your Claude Code configuration.

### 2. Install Dependencies

```bash
# At your project root
npm install openai --save
```

### 3. Set API Key

```bash
# Add to your shell config (~/.zshrc or ~/.bashrc)
export OPENAI_API_KEY=sk-your-key-here
```

### 4. Copy the Script

Copy `scripts/gen-image.ts` to your project's `scripts/` directory.

### 5. Setup Output Directory

```bash
mkdir -p assets/generated

# Add to .gitignore
echo "assets/generated/*.png" >> .gitignore
echo "assets/generated/*.json" >> .gitignore
```

## Usage

### Command

```bash
/gen-image "your prompt here" [options]
```

### Options

| Option | Values | Default |
|--------|--------|---------|
| `--size` | 1024x1024, 1792x1024, 1024x1792 | 1024x1024 |
| `--model` | gpt-image-1, dall-e-3, dall-e-2 | gpt-image-1 |
| `--quality` | auto, low, medium, high, hd | auto |
| `--out` | filename.png | timestamp.png |

### Examples

```bash
# Basic logo
/gen-image "Minimalist chef hat logo, flat vector style, black on white"

# Hero image (wide)
/gen-image "Hero illustration for cooking app, warm kitchen scene" --size 1792x1024

# High quality with custom name
/gen-image "Premium food photography, pasta dish" --quality hd --out pasta-hero.png
```

## Output

Images are saved to `assets/generated/`:

```
assets/generated/
├── 2024-01-15T10-30-45.png    # Generated image
├── 2024-01-15T10-30-45.json   # Metadata (prompt, settings)
└── ...
```

## Use Cases

- **Logo Exploration**: Generate 10-20 logo directions quickly
- **Marketing Assets**: Hero images, ad creatives, social graphics
- **UI Illustrations**: Feature cards, empty states, icons
- **Brand Moodboards**: Visual direction exploration

## Prompt Tips

### For Logos
```
"Minimalist logo mark: [subject], flat vector style, [colors], no text"
"Hand-drawn logo: [subject], expressive lines, simple design"
```

### For Marketing
```
"Hero illustration for [product], [style], wide composition"
"Ad creative: [product/scene], professional photography style"
```

## Important Notes

- Generated images are **raster** (PNG) - for production logos, recreate as vectors
- `gpt-image-1` has the best instruction following
- Keep prompts specific but not overly complex
- Iterate: generate variations, then refine the best direction

## Requirements

- Node.js 18+
- OpenAI API key with image generation access
- `openai` npm package
- `tsx` (via npx)

## License

MIT
