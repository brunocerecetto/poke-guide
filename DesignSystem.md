# Design System Specification

## 1. Overview & Creative North Star: "The Kinetic Archive"
This design system moves away from the "toy-like" aesthetic often associated with the genre, opting instead for a high-end, editorial experience titled **"The Kinetic Archive."** The North Star focuses on the Pokémon as rare, high-value specimens within a digital vault. 

We break the "template" look by utilizing intentional asymmetry—such as oversized Pokédex numbers that bleed off-canvas—and a hierarchy that prioritizes breathing room over information density. The goal is an interface that feels like a premium collector's tool: immersive, energetic, and surgically organized.

## 2. Colors & Surface Philosophy
The palette utilizes the iconic primary tones of the franchise but reinterprets them through the lens of Material 3 functional roles to ensure sophisticated contrast and accessibility.

### The "No-Line" Rule
Standard 1px solid borders are strictly prohibited for sectioning. Structural boundaries must be defined solely through background color shifts. For example, a `surface-container-low` card sitting on a `surface` background provides all the separation required. If a layout feels "mushy," increase the contrast between container tiers rather than reaching for a stroke.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. We use a "Nested Depth" approach:
- **Level 0 (Base):** `surface` (#f9f9f9) - The canvas.
- **Level 1 (Sectioning):** `surface-container-low` (#f3f3f3) - Large structural areas.
- **Level 2 (Interaction):** `surface-container-highest` (#e2e2e2) - Interactive elements or nested cards.
- **Level 3 (Overlay):** Glassmorphic layers using `surface_variant` at 40-60% opacity with a 20px backdrop blur.

### The "Glass & Gradient" Rule
To elevate the app beyond a flat utility, main CTAs and Hero sections should utilize "Signature Textures." 
- **The Energy Gradient:** Transition from `primary` (#bc0100) to `primary_container` (#eb0000) at a 135° angle.
- **The Depth Blur:** Floating Pokémon sprites should sit on glassmorphic pedestals using the `surface_lowest` token with a subtle `outline_variant` "Ghost Border" (15% opacity).

## 3. Typography: Editorial Impact
We utilize a dual-font strategy to balance character and legibility.

- **Display & Headlines (`plusJakartaSans`):** This is our "voice." Use `display-lg` for Pokémon names and `headline-lg` for section headers. These should be set with tight letter-spacing (-0.02em) to feel bold and authoritative.
- **Body & Labels (`inter` / SF Pro):** This is our "engine." Use `body-md` for descriptions and `label-sm` for technical stats (Height, Weight, Base XP). 

**Editorial Note:** Use dramatic scale shifts. A `display-lg` Pokédex number (e.g., #0006) should be 4x the size of the accompanying `title-md` name to create a sense of scale and importance.

## 4. Elevation & Depth
Depth is achieved through **Tonal Layering** rather than traditional drop shadows.

- **The Layering Principle:** Stack `surface-container-lowest` cards on `surface-container-low` backgrounds to create a soft, natural lift.
- **Ambient Shadows:** When a "floating" effect is mandatory (e.g., a Bottom Sheet or FAB), use highly diffused shadows: `Blur: 40px`, `Spread: -10px`, `Opacity: 6%` of the `on_surface` color.
- **The Ghost Border:** For accessibility on white-on-white elements, use the `outline_variant` token at **10% opacity**. It should be felt, not seen.
- **Glassmorphism:** Use backdrop-blur (minimum 20px) on any card containing high-quality type icons (Fire, Water, etc.). This allows the vibrant type colors to bleed into the UI, creating an "immersive" color-spill effect.

## 5. Components

### Buttons
- **Primary:** Rounded `xl` (3rem). Background: Energy Gradient (Primary to Primary Container). Text: `on_primary` Bold.
- **Secondary:** Rounded `xl` (3rem). Background: `secondary_container` (#0356ff). This is reserved for "Great Ball" tier actions (e.g., Evolution, Trading).
- **Tertiary:** `surface-container-highest` with `primary` text. Use for low-priority utility.

### Cards & Lists
- **The Divider Ban:** Never use horizontal rules. Separate list items using `1.5rem` (`md`) of vertical whitespace or by alternating `surface` and `surface-container-low` backgrounds.
- **Pokémon Cards:** Use `lg` (2rem) corner radius. The background should be a subtle glassmorphism overlay if the background has a Pokémon-type gradient.

### Type Badges (Chips)
- **Styling:** Small, pill-shaped (`full` rounding).
- **Visuals:** Instead of flat colors, use a 10% opacity version of the Type Color (e.g., Fire Red) with a high-saturation icon. This ensures the UI remains "Professional" and not "Cartoonish."

### Input Fields
- **State:** `surface-container-highest` background. No border.
- **Focus:** Transition the background to `primary_fixed` with a `primary` "Ghost Border" at 20% opacity.

## 6. Do's and Don'ts

### Do:
- **DO** use the `xl` (3rem) corner radius for main containers to emphasize the "playful yet professional" vibe.
- **DO** use "Overlapping" elements. Let a high-fidelity 3D Pokémon render break the bounds of its card container to create depth.
- **DO** utilize `surface_bright` for active, selected states in navigation.

### Don't:
- **DON'T** use pure black (#000000). Use `on_surface` (#1a1c1c) for text and `inverse_surface` (#2f3131) for dark-mode-style elements.
- **DON'T** use standard iOS dividers. If content needs separation, use the Spacing Scale (Default: 1rem).
- **DON'T** crowd the screen. If a screen has more than 5 primary interaction points, move the secondary actions into a "Ghost Border" container or a kebab menu.
