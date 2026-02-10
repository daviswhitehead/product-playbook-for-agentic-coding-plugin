#!/usr/bin/env npx tsx
/**
 * OpenAI Image Generation Script
 *
 * Usage:
 *   npx tsx scripts/gen-image.ts "your prompt here"
 *   npx tsx scripts/gen-image.ts "your prompt here" --size 1792x1024
 *   npx tsx scripts/gen-image.ts "your prompt here" --model gpt-image-1
 *   npx tsx scripts/gen-image.ts "your prompt here" --out custom-name.png
 *   npx tsx scripts/gen-image.ts "your prompt here" --quality hd
 *
 * Or via npm script:
 *   npm run gen:image -- "your prompt here"
 */

import OpenAI from 'openai';
import * as fs from 'fs';
import * as path from 'path';

interface Options {
  prompt: string;
  size: '1024x1024' | '1024x1792' | '1792x1024';
  model: string;
  quality: 'auto' | 'low' | 'medium' | 'high' | 'hd';
  outputName?: string;
}

function parseArgs(): Options {
  const args = process.argv.slice(2);

  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    console.log(`
OpenAI Image Generation Script

Usage:
  npx tsx scripts/gen-image.ts "your prompt here" [options]

Options:
  --size      Image size: 1024x1024 (default), 1024x1792, 1792x1024
  --model     Model: gpt-image-1 (default), dall-e-3, dall-e-2
  --quality   Quality: auto (default), low, medium, high, hd
  --out       Output filename (default: timestamp-based)
  --help, -h  Show this help

Examples:
  npx tsx scripts/gen-image.ts "Chef Chopsky logo: minimal badge with chef hat and spoon, flat vector style, 2 colors"
  npx tsx scripts/gen-image.ts "Hero illustration for restaurant app" --size 1792x1024 --quality hd
  npx tsx scripts/gen-image.ts "Ad creative: delicious pasta dish" --out pasta-hero.png
`);
    process.exit(0);
  }

  const options: Options = {
    prompt: args[0],
    size: '1024x1024',
    model: 'gpt-image-1',
    quality: 'auto',
  };

  for (let i = 1; i < args.length; i++) {
    const arg = args[i];
    const nextArg = args[i + 1];

    switch (arg) {
      case '--size':
        if (nextArg && ['1024x1024', '1024x1792', '1792x1024'].includes(nextArg)) {
          options.size = nextArg as Options['size'];
          i++;
        } else {
          console.error('Invalid size. Use: 1024x1024, 1024x1792, or 1792x1024');
          process.exit(1);
        }
        break;
      case '--model':
        if (nextArg) {
          options.model = nextArg;
          i++;
        }
        break;
      case '--quality':
        if (nextArg && ['auto', 'low', 'medium', 'high', 'hd'].includes(nextArg)) {
          options.quality = nextArg as Options['quality'];
          i++;
        } else {
          console.error('Invalid quality. Use: auto, low, medium, high, or hd');
          process.exit(1);
        }
        break;
      case '--out':
        if (nextArg) {
          options.outputName = nextArg;
          i++;
        }
        break;
    }
  }

  return options;
}

async function generateImage(options: Options): Promise<string> {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    console.error('Error: OPENAI_API_KEY environment variable not set');
    console.error('Set it with: export OPENAI_API_KEY=your-key');
    console.error('Or use Doppler: doppler run -- npx tsx scripts/gen-image.ts "prompt"');
    process.exit(1);
  }

  const openai = new OpenAI({ apiKey });

  console.log(`\n🎨 Generating image...`);
  console.log(`   Model: ${options.model}`);
  console.log(`   Size: ${options.size}`);
  console.log(`   Quality: ${options.quality}`);
  console.log(`   Prompt: "${options.prompt.substring(0, 80)}${options.prompt.length > 80 ? '...' : ''}"`);
  console.log('');

  // gpt-image-1 uses different API params than dall-e models
  const isGptImage = options.model.startsWith('gpt-image');

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const generateParams: any = {
    model: options.model,
    prompt: options.prompt,
    n: 1,
    size: options.size,
  };

  // Only add quality for dall-e models
  if (!isGptImage) {
    generateParams.response_format = 'b64_json';
    generateParams.quality = options.quality === 'hd' || options.quality === 'high' ? 'hd' : 'standard';
  }

  const response = await openai.images.generate(generateParams);

  let imageBuffer: Buffer;

  // Check what type of response we got
  const imageResult = response.data[0];

  if (imageResult?.b64_json) {
    // Base64 response (dall-e models with response_format: b64_json, or gpt-image-1 default)
    imageBuffer = Buffer.from(imageResult.b64_json, 'base64');
  } else if (imageResult?.url) {
    // URL response - need to download the image
    console.log('   Downloading image from URL...');
    const imageResponse = await fetch(imageResult.url);
    if (!imageResponse.ok) {
      throw new Error(`Failed to download image: ${imageResponse.statusText}`);
    }
    const arrayBuffer = await imageResponse.arrayBuffer();
    imageBuffer = Buffer.from(arrayBuffer);
  } else {
    throw new Error('No image data returned from OpenAI');
  }

  // Generate output path
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const filename = options.outputName || `${timestamp}.png`;
  const outputDir = path.join(__dirname, '..', 'assets', 'generated');
  const outputPath = path.join(outputDir, filename);

  // Ensure output directory exists
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Save image
  fs.writeFileSync(outputPath, imageBuffer);

  // Save prompt alongside for reference
  const metadataPath = outputPath.replace('.png', '.json');
  fs.writeFileSync(
    metadataPath,
    JSON.stringify(
      {
        prompt: options.prompt,
        model: options.model,
        size: options.size,
        quality: options.quality,
        generated_at: new Date().toISOString(),
        revised_prompt: response.data[0]?.revised_prompt,
      },
      null,
      2
    )
  );

  return outputPath;
}

async function main() {
  const options = parseArgs();

  try {
    const outputPath = await generateImage(options);
    console.log(`✅ Image saved to: ${outputPath}`);
    console.log(`📄 Metadata saved to: ${outputPath.replace('.png', '.json')}`);

    // Print relative path for easy copying
    const relativePath = path.relative(process.cwd(), outputPath);
    console.log(`\n📋 Relative path: ${relativePath}`);
  } catch (error) {
    if (error instanceof Error) {
      console.error(`\n❌ Error: ${error.message}`);
    } else {
      console.error('\n❌ An unexpected error occurred');
    }
    process.exit(1);
  }
}

main();
