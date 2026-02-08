---
name: mobile-debugging
description: Patterns for debugging mobile-specific issues on iOS Safari and Android Chrome. Use this skill when encountering viewport, keyboard, or touch-related bugs that only reproduce on real mobile devices.
---

# Mobile Debugging

This skill provides patterns for debugging mobile-specific issues, particularly viewport and keyboard handling differences between iOS Safari and Android Chrome.

## When to Use This Skill

Use this skill when:
- Bugs only reproduce on real mobile devices (not emulators)
- Issues involve keyboard appearance/dismissal
- Problems with viewport sizing or scrolling
- Overscroll or bounce behavior issues
- Touch input behaves differently than expected

## Critical Insight: Real Devices Required

**Many mobile bugs cannot be reproduced in:**
- Browser developer tools device emulation
- Playwright/Puppeteer automated tests
- iOS Simulator or Android Emulator

**Always test on real physical devices** for:
- Keyboard viewport resizing
- Overscroll/bounce behavior
- Touch gesture nuances
- Safari-specific viewport handling

### Testing Setup Recommendations

1. **Local device testing**: Use ngrok to expose localhost
2. **Preview deployments**: Deploy to Vercel/Netlify preview
3. **Multiple devices**: Test on both iOS (Safari) and Android (Chrome)

## Platform Behavior Differences

iOS Safari and Android Chrome handle viewports completely differently:

| Behavior | Android Chrome | iOS Safari |
|----------|---------------|------------|
| `interactiveWidget: resizes-content` | ✅ Resizes viewport | ❌ Ignored |
| `100dvh` on keyboard open | ✅ Shrinks correctly | ⚠️ Layout viewport unchanged |
| `scrollIntoView()` with keyboard | ✅ Works immediately | ❌ Needs 350ms delay |
| Keyboard dismiss detection | Via resize event | Via focusout/blur |
| Overscroll prevention | `overscroll-behavior` works | May need additional handling |

**Key Implication**: CSS-only solutions (`dvh` units, viewport meta) work on Android but require JavaScript workarounds on iOS Safari.

## Common Mobile Bug Patterns

### Pattern 1: Input Covered by Keyboard (iOS Safari)

**Symptom**: When focusing an input, the keyboard covers it instead of scrolling into view.

**Root Cause**: iOS Safari doesn't resize the layout viewport when the keyboard appears.

**Solution**: Add `scrollIntoView` on focus with delay:

```typescript
const handleFocus = () => {
  // Wait for iOS keyboard animation (~300ms)
  setTimeout(() => {
    element.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }, 350);
};
```

**Apply to**: All inputs that could be near the bottom of the screen (chat inputs, login forms, comment boxes).

### Pattern 2: Gray Space Below Content

**Symptom**: User can scroll past content to reveal gray/white space below.

**Root Cause**: Usually a wrapper element with `min-h-screen` or `min-height: 100vh` that extends beyond the viewport.

**Debugging Steps**:
1. Check `layout.tsx` or root layout for wrapper divs
2. Look for `min-h-screen`, `min-h-full`, or `min-height` properties
3. Check if body has `overflow: auto` instead of `overflow: hidden`

**Solution**:
```css
/* globals.css */
html, body {
  height: 100%;
  overflow: hidden;
  overscroll-behavior: none;
}
```

**And**: Remove wrapper divs with `min-h-screen`. Let pages handle their own height with `h-dvh`.

### Pattern 3: Flex Layout Not Filling Height

**Symptom**: Components don't fill available vertical space properly.

**Root Cause**: Broken flex layout cascade - using `h-full` instead of `flex-1`.

**Solution**: Ensure flex layout cascades through component tree:

```tsx
// ❌ Wrong
<View className="flex-1">
  <ChildComponent className="h-full" />  {/* Won't fill properly */}
</View>

// ✅ Correct
<View className="flex-1 flex flex-col">
  <ChildComponent className="flex-1" />  {/* Fills remaining space */}
</View>
```

### Pattern 4: Textarea Doesn't Shrink

**Symptom**: After deleting all text (select all + delete), textarea stays expanded.

**Root Cause**: `scrollHeight` doesn't immediately reflect empty content.

**Solution**: Explicitly check for empty value:

```typescript
const adjustHeight = () => {
  if (!value || value.length === 0) {
    element.style.height = `${minHeight}px`;
    return;
  }
  // ... normal scrollHeight calculation
};
```

### Pattern 5: Overscroll Bounce

**Symptom**: Page bounces when scrolling past content edges.

**Solution**:
```css
body {
  overscroll-behavior: none;
}
```

For scroll containers:
```tsx
<ScrollView
  bounces={false}  // iOS
  overScrollMode="never"  // Android
/>
```

## Debugging Checklist

When encountering a mobile-specific bug:

### Step 1: Get Real Device Evidence
- [ ] Screenshot from real iOS device (Safari)
- [ ] Screenshot from real Android device (Chrome)
- [ ] Confirm bug doesn't reproduce in browser dev tools

### Step 2: Check Root Layout First
- [ ] Check viewport meta tags in `layout.tsx`
- [ ] Look for `min-h-screen` wrappers
- [ ] Verify `overflow: hidden` on html/body
- [ ] Check for `interactiveWidget` setting

### Step 3: Check Component Layout
- [ ] Verify flex layout cascades properly (`flex-1` not `h-full`)
- [ ] Check for fixed heights that might conflict
- [ ] Look for unnecessary scroll containers

### Step 4: Platform-Specific Checks
- [ ] For iOS keyboard issues: Add `scrollIntoView` with 350ms delay
- [ ] For Android keyboard issues: Verify `interactiveWidget: resizes-content`
- [ ] For overscroll: Add `overscroll-behavior: none`

## Viewport Meta Tag Reference

```tsx
// layout.tsx
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,  // Prevents zoom on input focus
  // Android: Make keyboard resize viewport instead of overlay
  interactiveWidget: 'resizes-content',
};
```

## Testing requestAnimationFrame in Jest

If your mobile fix uses `requestAnimationFrame`, tests may fail because Jest doesn't execute rAF callbacks synchronously.

**Solution**: Mock rAF in tests:

```typescript
beforeEach(() => {
  jest.spyOn(window, 'requestAnimationFrame').mockImplementation((cb) => {
    cb(0);
    return 0;
  });
});

afterEach(() => {
  jest.restoreAllMocks();
});
```

## References

- [MDN VisualViewport API](https://developer.mozilla.org/en-US/docs/Web/API/VisualViewport)
- [Chrome Viewport Resize Behavior](https://developer.chrome.com/blog/viewport-resize-behavior)
- [iOS Safari Keyboard Detection](https://martijnhols.nl/blog/how-to-detect-the-on-screen-keyboard-in-ios-safari)
- [CSS-Tricks Auto-Growing Textareas](https://css-tricks.com/the-cleanest-trick-for-autogrowing-textareas/)

## Summary

Mobile debugging requires:
1. **Real devices** - Emulators don't reproduce many bugs
2. **Platform awareness** - iOS Safari ≠ Android Chrome
3. **Root-level checks first** - Viewport meta, body overflow, wrapper elements
4. **JavaScript workarounds for iOS** - `scrollIntoView` with delays

## Integration with Playbook

This skill works with:
- `/playbook:debug` - Use this skill during mobile debugging sessions
- `/playbook:learnings` - Capture mobile-specific fixes for future reference
- `debugging-agent` - Provides mobile-specific debugging patterns

---

*When in doubt: check on a real device, check the root layout, and remember iOS Safari needs special handling.*
