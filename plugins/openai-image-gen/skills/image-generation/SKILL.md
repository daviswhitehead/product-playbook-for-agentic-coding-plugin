---
name: image-generation
description: Generate images using OpenAI's API. Use this skill when creating logos, illustrations, marketing assets, or any visual content that can be generated from text prompts.
---

# Image Generation Skill

This skill enables Claude Code to generate images using OpenAI's image generation API, making it possible to create visual assets directly during development workflows.

## When to Use This Skill

Use image generation for:

- **Logo exploration**: Generate multiple logo directions quickly
- **Marketing assets**: Hero images, ad creatives, social media graphics
- **UI illustrations**: Icons, feature cards, empty states
- **Brand moodboards**: Visual direction exploration
- **Mockup content**: Placeholder images with actual relevant content

## When NOT to Use This Skill

- **Final production logos**: Generated images are raster; recreate as vectors
- **Photography replacement**: Use real photos for authenticity
- **Trademarked content**: Don't generate content mimicking existing brands
- **Precise technical diagrams**: Use dedicated diagramming tools

## Prerequisites

Before using this skill, ensure:

1. **OPENAI_API_KEY** is set in environment
2. **openai** package is installed (`npm install openai`)
3. **scripts/gen-image.ts** exists in project root

## Quick Setup

If not already set up:

```bash
# Install dependency
npm install openai --save

# Create output directory
mkdir -p assets/generated

# Add to .gitignore
echo "assets/generated/*.png" >> .gitignore
echo "assets/generated/*.json" >> .gitignore
```

## Usage Patterns

### Pattern 1: Single Image Generation

For a specific, well-defined need:

```bash
npx tsx scripts/gen-image.ts "Your detailed prompt here" --out descriptive-name.png
```

### Pattern 2: Batch Exploration

Generate multiple variations to explore directions:

```bash
# Generate variations with different styles
npx tsx scripts/gen-image.ts "Chef logo, minimalist line art" --out logo-v1-lineart.png
npx tsx scripts/gen-image.ts "Chef logo, bold geometric shapes" --out logo-v2-geometric.png
npx tsx scripts/gen-image.ts "Chef logo, hand-drawn sketch style" --out logo-v3-sketch.png
npx tsx scripts/gen-image.ts "Chef logo, negative space design" --out logo-v4-negative.png
```

### Pattern 3: Iterative Refinement

Start broad, then refine:

```bash
# Round 1: Broad exploration
npx tsx scripts/gen-image.ts "Modern cooking app logo concepts"

# Round 2: Refine promising direction
npx tsx scripts/gen-image.ts "Minimalist chef hat logo, single line weight, friendly curves"

# Round 3: Final refinement
npx tsx scripts/gen-image.ts "Minimalist chef hat logo, single continuous line, slightly playful tilt, warm personality"
```

## Prompt Engineering Guide

### Structure for Effective Prompts

```
[Subject] + [Style] + [Details] + [Constraints]
```

**Example:**
```
"Chef hat with knife" + "minimalist line art" + "hand-drawn quality, organic lines" + "black on white, no text"
```

### Style Keywords That Work Well

**For Logos:**
- "minimalist", "flat vector", "line art", "geometric"
- "hand-drawn", "sketch style", "organic lines"
- "negative space", "optical illusion"
- "badge design", "emblem style", "monogram"

**For Marketing:**
- "hero illustration", "feature card"
- "isometric", "3D render", "flat design"
- "photography style", "editorial"
- "warm lighting", "dramatic shadows"

**For Consistency:**
- Specify exact colors: "warm orange (#FF6B35) and cream (#FFF5E1)"
- Specify style: "in the style of Stripe illustrations"
- Specify constraints: "no gradients", "single stroke weight"

### Color Specification

```bash
# Named colors
"...using warm orange and cream colors"

# Specific palette
"...color palette: deep navy (#1a365d), gold (#d69e2e), white"

# Monochrome
"...black linework on pure white background"
```

## Output Management

### File Organization

Generated files go to `assets/generated/`:

```
assets/generated/
├── 2024-01-15T10-30-45.png      # Timestamped image
├── 2024-01-15T10-30-45.json     # Metadata
├── logo-exploration-v1.png      # Named image
├── logo-exploration-v1.json     # Metadata
└── ...
```

### Metadata Files

Each image has a companion JSON with:
- Original prompt
- Model used
- Size and quality settings
- Generation timestamp
- Revised prompt (if model modified it)

Use metadata to:
- Track successful prompts
- Iterate on good directions
- Document design decisions

## Integration with Design Workflow

### Logo Development Workflow

1. **Explore** (5-10 images): Generate diverse directions
2. **Select** (2-3 directions): Pick promising concepts
3. **Refine** (3-5 per direction): Iterate on selected concepts
4. **Finalize**: Pick best, recreate as vector in Figma/Illustrator

### Marketing Asset Workflow

1. **Generate**: Create image with appropriate size (1792x1024 for hero)
2. **Review**: Check composition, colors, messaging alignment
3. **Iterate**: Refine prompt based on feedback
4. **Export**: Use directly or as basis for final asset

## Size Guidelines

| Use Case | Recommended Size | Flag |
|----------|------------------|------|
| Logo/Icon | 1024x1024 | (default) |
| Hero Banner | 1792x1024 | `--size 1792x1024` |
| Portrait/Story | 1024x1792 | `--size 1024x1792` |
| Social Square | 1024x1024 | (default) |

## Model Selection

| Model | Best For | Notes |
|-------|----------|-------|
| gpt-image-1 | General use, best instruction following | Default, recommended |
| dall-e-3 | Photorealistic, complex scenes | Higher quality, slower |
| dall-e-2 | Quick iterations, simpler needs | Faster, less detailed |

## Troubleshooting

### Common Issues

**Prompt too literal:**
- Add style keywords: "artistic interpretation", "stylized"
- Reduce specificity in some areas

**Results too busy:**
- Add constraints: "simple", "minimal", "clean"
- Specify what to exclude: "no background elements", "no text"

**Wrong aspect ratio feel:**
- Change size even if dimensions are correct
- Add composition hints: "centered", "wide composition"

**Inconsistent style:**
- Be more specific about style in prompt
- Reference specific design movements or artists (carefully)

## Best Practices

1. **Save good prompts**: When you get a great result, save the prompt for reuse
2. **Iterate in batches**: Generate 3-5 variations before refining
3. **Use descriptive filenames**: `logo-chef-hat-lineart-v2.png` not `image1.png`
4. **Review metadata**: Check if the model revised your prompt (insight into what worked)
5. **Version control prompts**: Keep a prompts.md in your project documenting what worked

## Example Prompts Library

### Logos
```
"Minimalist logo mark: chef hat silhouette, single continuous line, friendly curves, black on white, no text"

"Modern badge logo: crossed kitchen utensils, circular frame, hand-drawn quality, two-tone design"

"Abstract logo: letter C formed by cooking flame, geometric, warm orange gradient, minimal"
```

### Marketing
```
"Hero illustration for cooking app: warm kitchen scene, morning light, fresh ingredients, editorial style, wide composition"

"Feature card: AI assistant concept, friendly robot character, flat illustration style, pastel colors, centered"

"Social media graphic: recipe of the day, overhead food photography style, natural lighting, square format"
```

### Icons
```
"App icon: chef hat, simple flat design, rounded corners style, single color on gradient background"

"UI icon set: cooking utensils, consistent line weight, minimal style, monochrome"
```

## Alternative Providers

This plugin focuses on OpenAI for simplicity. For specific use cases, other providers may be better:

| Use Case | Consider |
|----------|----------|
| Text-heavy logos | Ideogram, Recraft |
| Photorealism | BFL (FLUX), Stability AI |
| Fast iterations | FAL |
| Image editing | Clipdrop, Stability |
| Artistic/fantasy | Leonardo |

For multi-provider support with automatic fallback, see [shipdeckai/claude-skills/image-gen](https://github.com/shipdeckai/claude-skills/tree/main/plugins/image-gen).

Detailed comparison: [references/alternative-providers.md](references/alternative-providers.md)

---

*Remember: AI-generated images are starting points. Final brand assets should be refined and often recreated as vectors for production use.*
