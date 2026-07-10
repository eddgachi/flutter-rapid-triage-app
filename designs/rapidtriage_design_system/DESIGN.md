---
name: RapidTriage Design System
colors:
  surface: '#fdf8fd'
  surface-dim: '#ddd9de'
  surface-bright: '#fdf8fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f2f8'
  surface-container: '#f1ecf2'
  surface-container-high: '#ebe7ec'
  surface-container-highest: '#e5e1e7'
  on-surface: '#1c1b1f'
  on-surface-variant: '#434654'
  inverse-surface: '#313034'
  inverse-on-surface: '#f4eff5'
  outline: '#737685'
  outline-variant: '#c3c6d6'
  surface-tint: '#0c56d0'
  primary: '#003d9b'
  on-primary: '#ffffff'
  primary-container: '#0052cc'
  on-primary-container: '#c4d2ff'
  inverse-primary: '#b2c5ff'
  secondary: '#005faf'
  on-secondary: '#ffffff'
  secondary-container: '#54a0fe'
  on-secondary-container: '#003567'
  tertiary: '#7b2600'
  on-tertiary: '#ffffff'
  tertiary-container: '#a33500'
  on-tertiary-container: '#ffc6b2'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001848'
  on-primary-fixed-variant: '#0040a2'
  secondary-fixed: '#d4e3ff'
  secondary-fixed-dim: '#a5c8ff'
  on-secondary-fixed: '#001c3a'
  on-secondary-fixed-variant: '#004786'
  tertiary-fixed: '#ffdbcf'
  tertiary-fixed-dim: '#ffb59b'
  on-tertiary-fixed: '#380d00'
  on-tertiary-fixed-variant: '#812800'
  background: '#fdf8fd'
  on-background: '#1c1b1f'
  surface-variant: '#e5e1e7'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-md:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-sm:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
  touch-target-min: 48px
---

## Brand & Style
This design system is engineered for high-stakes emergency medical environments where cognitive load must be minimized and speed of action is paramount. The brand personality is professional, clinical, and uncompromisingly utility-focused. It prioritizes functional reliability over decorative flair, ensuring that paramedics can navigate complex triage workflows under extreme pressure.

The visual style follows a **Modern Corporate** approach with a heavy emphasis on **High-Contrast / Bold** elements for critical information. It leverages Material 3 principles to provide a familiar, systematic structure while introducing specialized patterns for offline-first synchronization states and rapid data entry. The UI evokes a sense of calm authority and technical precision, ensuring the interface remains a tool, never a distraction.

## Colors
The color palette is functionally mapped to medical urgency and system state. The primary **Deep Medical Blue** provides a stable, professional foundation for the application shell. 

Triage levels use a standardized color-coding system to ensure immediate recognition:
- **P1 (Critical):** High-saturation Red for life-threatening conditions.
- **P2 (High):** Safety Orange for urgent but stable patients.
- **P3 (Medium):** Amber for delayed care.
- **P4 (Low):** Success Green for minor injuries.
- **P5 (Minimal):** Calm Blue for non-urgent tracking.

The system supports both Light and Dark modes. Dark mode is specifically optimized for night-time field operations to reduce screen glare and preserve the user's night vision. Status colors for "Synced," "Offline," and "Error" must be used consistently in the header or status bar to provide constant feedback on the app's offline-first connectivity state.

## Typography
**Inter** is the exclusive typeface for this design system, chosen for its exceptional legibility in low-light and high-vibration environments (such as a moving ambulance). 

- **Numerical Data:** Use `headline-lg` or `display-lg` for vital signs and timers to ensure they are readable at arm's length.
- **Labels:** Use `label-lg` for form headers and field descriptors to ensure clarity during rapid data entry.
- **Tight Layouts:** In data-heavy lists, use `body-md` for secondary patient details to maintain high information density without sacrificing legibility.
- **Letter Spacing:** Increased letter spacing is applied to labels to prevent character blurring under stress.

## Layout & Spacing
This design system utilizes a strict **8dp grid system**. All dimensions, padding, and margins must be multiples of 8px (or 4px for fine-grained alignment). 

**Layout Model:**
- **Mobile:** A 4-column fluid grid with 16px margins. Primary actions are housed in a **Sticky Footer** to ensure they are always within thumb reach.
- **Tablet:** A 12-column grid. The layout utilizes a "Master-Detail" pattern where the patient list stays on the left and the triage form opens on the right.
- **Touch Targets:** A minimum touch target of 48x48dp is mandatory for all interactive elements to accommodate gloved hands and high-stress movement.

**Spacing Rhythm:**
Use `md` (16px) for standard padding within cards and `lg` (24px) for separating major logical sections.

## Elevation & Depth
Elevation is used functionally to indicate hierarchy and interactability. The system uses **Tonal Layers** supplemented by subtle **Ambient Shadows**.

- **Level 0 (Surface):** The lowest layer, used for the main background.
- **Level 1 (Cards):** Triage cards use a slight elevation with a 1px low-contrast outline to define boundaries clearly in both light and dark modes.
- **Level 2 (Modals/Menus):** Higher elevation with a more pronounced shadow to pull focus during critical alerts or confirmation dialogs.
- **Sticky Elements:** Footers and Headers have a Level 1 elevation to appear as if they are floating above the scrollable content, ensuring the "Complete Triage" button is always identifiable.
- **No Shadows on Inputs:** Form fields remain flat with high-contrast borders to ensure maximum legibility of the input text.

## Shapes
The shape language balances modern aesthetics with clinical precision.

- **Cards and Containers:** Use a `0.5rem` (8px) corner radius. This creates a soft enough look to be professional while maintaining a structured, efficient feel that maximizes screen real estate.
- **Buttons:** Use a **Pill-shaped** (full round) radius. This makes primary actions highly distinct from informational cards, signaling clear interactability.
- **Input Fields:** Use a `0.25rem` (4px) or `0.5rem` (8px) radius to maintain a consistent look with the container system.
- **Status Badges:** Use a pill shape for triage priority indicators (P1-P5) to make them look like physical tags.

## Components
### Buttons
Buttons are pill-shaped and have a minimum height of 48dp. Primary buttons use the `Primary Medical Blue` background with white text. Critical actions (e.g., "Declare Deceased" or "Delete") use the `Critical P1 Red`.

### Triage Cards
Cards must have a high-contrast vertical "color bar" on the left edge corresponding to the patient's triage priority. This allows for rapid scanning of a list to identify the most critical patients.

### Input Fields
Fields should be "Filled" style (Material 3) with a high-contrast bottom border. Labels must always remain visible (no disappearing placeholders) to prevent errors in high-stress data entry.

### Sticky Footers
Used for primary workflow transitions (e.g., "Next Section," "Submit Triage"). The footer should have a slight background blur or solid surface color to ensure text legibility over scrolling content.

### Status Badges
Small, high-contrast badges used in the header to indicate "Syncing," "Offline Mode," or "Database Locked." These must include both an icon and text for accessibility.

### Large-Scale Toggles
For binary choices (e.g., Conscious/Unconscious), use large segmented buttons that span the width of the screen to provide the largest possible hit area.