# /progress Page Design Specification

**Version:** 1.0  
**Last Updated:** 2026  
**Style:** Brutal-Premium Glassmorphic (2026)

---

## Overview

The `/progress` page is a comprehensive tactical dashboard that displays workout analytics, muscle distribution, personal records, and training streaks. It follows the "Steal Forges Steel" brutal-premium aesthetic with heavy transparency, glassmorphism, and forged-steel visual elements.

---

## Visual Design System

### Color Palette

| Element | Color | Usage |
|---------|-------|-------|
| Accent (Forge Orange) | `#FF4D00` / `#C2410C` | Primary actions, highlights, dominant stats |
| Steel (Neutral) | `#C8C8C8` | Secondary elements, balanced metrics |
| Tactical Green | `#22C55E` | Success states, legs/pull metrics |
| Background Dark | `#0A0A0A` | Base backgrounds |
| Glass Overlay | `rgba(10,10,10,0.6)` | Card backgrounds with blur |
| Border Subtle | `rgba(255,255,255,0.06)` | Card borders, dividers |
| Text Primary | `#E5E5E5` | Main text |
| Text Muted | `#71717A` | Secondary text, labels |
| Text Dim | `#525252` | Disabled, placeholder text |

### Typography

| Style | Font | Size | Weight | Tracking |
|-------|------|------|--------|----------|
| Heading | var(--font-heading) | 3xl | 800 (black) | -0.02em |
| Data | var(--font-data) | 8px-10px | 600-700 | 0.2em |
| Stamp | var(--font-mono) | 7px-14px | 400-700 | 0.15em |
| Body | var(--font-sans) | 14px | 400 | normal |

### Animation Timing

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Enter animations | 300-400ms | `cubic-bezier(0.23, 1, 0.32, 1)` |
| Bar fills | 550-650ms | `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| Hover states | 150-200ms | `ease-out` |
| Neon pulse | 2.2s | `ease-in-out infinite` |

---

## Component Specifications

### 1. MuscleRadar.tsx

**Purpose:** 5-sided pentagon radar chart showing muscle group volume distribution

**Props:**
```typescript
interface PentagonDataPoint {
  label: "BACK" | "CHEST" | "SHOULDERS" | "ARMS" | "LEGS";
  value: number;      // Percentage (0-100)
  volumeKg: number;   // Total volume in kg
}

interface MuscleRadarProps {
  data: PentagonDataPoint[];
  className?: string;
}
```

**Visual Elements:**
- **Grid:** 4 concentric pentagons at 25%, 50%, 75%, 100% opacity (rgba(200,200,200,0.07))
- **Axes:** 5 radial lines from center with stroke rgba(200,200,200,0.1)
- **Data Polygon:** Filled with `rgba(255,77,0,0.40)` with animated entrance
- **Axis Labels:** Monospace 9px, positioned on pentagon vertices
- **Dominant Axis:** Highlighted with `#FF4D00` color and larger dot (4px vs 3px)
- **Hover States:** Transparent hit circles (r=18) around labels trigger tooltip

**Mobile Fallback:** Horizontal bar chart for screens < 640px

**Animation:**
```css
@keyframes radarIn {
  from { opacity: 0; transform: scale(0.82); }
  to   { opacity: 1; transform: scale(1); }
}
```

---

### 2. MuscleBalance.tsx

**Purpose:** Vertical bar chart comparing PUSH/PULL/LEGS training distribution

**Props:**
```typescript
interface MuscleBalanceProps {
  push: number;      // Push exercise count
  pull: number;      // Pull exercise count
  legs: number;      // Legs exercise count
  pushVol?: number;  // Optional volume in kg
  pullVol?: number;
  legsVol?: number;
  className?: string;
}
```

**Visual Elements:**
- **Dominant Badge:** Top badge showing "X DOMINANT" in dominant color
- **Bars:** 50px wide, up to 110px height, animated fill from bottom
- **Percentages:** Large 13px monospace numbers above bars
- **Labels:** 9px stamp text below bars
- **Volume Tooltip:** Appears on hover showing kg total
- **Balance Strip:** Segmented bar at bottom showing proportional split

**Color Mapping:**
| Split | Color |
|-------|-------|
| PUSH | `#FF4D00` (orange) |
| PULL | `#C8C8C8` (steel) |
| LEGS | `#22C55E` (green) |

**Dominant Bar Effect:**
```css
@keyframes neonPulse {
  0%,100% { box-shadow: 0 0 4px var(--nb-c); }
  50%      { box-shadow: 0 0 18px var(--nb-c), 0 0 36px var(--nb-c); }
}
```

---

### 3. PRWall.tsx

**Purpose:** Display top 3 personal records as glass cards with badge icons

**Props:**
```typescript
interface PRRecord {
  exerciseName: string;
  weight: number;        // Actual weight lifted
  reps: number;          // Reps achieved
  date: string;          // ISO date string
  estimated1RM: number;  // Calculated 1RM
}

interface PRWallProps {
  records: PRRecord[];
  className?: string;
}
```

**Visual Elements:**
- **Card Layout:** 3-column grid (1 column on mobile)
- **Background:** `rgba(10,10,10,0.6)` with `backdrop-filter: blur(12px)`
- **Border:** `1px solid rgba(255,255,255,0.06)`
- **Top Accent:** Gradient bar matching badge color with glow

**Badge Icons (rotating by index):**
| Index | Icon | Color | Label |
|-------|------|-------|-------|
| 0 | Trophy | `#FFD700` | GOLD |
| 1 | Zap | `#FF4D00` | SPEED |
| 2 | Flame | `#22C55E` | FIRE |

**Card Content:**
1. Badge label (7px, colored)
2. Exercise name (11px, uppercase, 800 weight)
3. e1RM value (24px, 800 weight, with text shadow glow)
4. Secondary stat: weight × reps (9px)
5. Date badge in bordered container (7px)

**Animations:**
```css
@keyframes sparkPulse {
  0%, 100% { transform: scale(1) rotate(0deg); opacity: 0.8; }
  50% { transform: scale(1.15) rotate(-10deg); opacity: 1; }
}
```

**Hover Effects:**
- Border lightens to `rgba(255,255,255,0.15)`
- Radial gradient glow appears from top center

---

## Layout Structure

### Page Container
```tsx
<div className="space-y-6 py-6">
  {/* Content sections */}
</div>
```

### Header Section
```tsx
<div className="border-b border-[#2a2a2a] pb-4">
  <h1 className="text-3xl font-extrabold uppercase tracking-tight text-[#e5e5e5]">
    STATS
  </h1>
  <div className="mt-2 h-0.5 w-12 bg-[#e53e00]" />
</div>
```

### KPI Row (4 columns on desktop)
```tsx
<div className="grid grid-cols-2 md:grid-cols-4 gap-3">
  {/* KPI panels */}
</div>
```

### Main Charts Row
```tsx
<div className="grid grid-cols-1 lg:grid-cols-3 gap-3">
  {/* Volume chart (col-span-2) */}
  {/* Trend chart (col-span-1) */}
</div>
```

---

## State Handling

### Loading State
```tsx
<SkeletonGrid />
// Renders skeleton cards with skeleton-steal class
```

### Empty State
```tsx
<EmptyState t={t} />
// Shows "NO DATA ACQUIRED" with motivational subtitle
```

### Error State
```tsx
<SignalLost onRetry={handleRetry} t={t} />
// Shows error panel with retry button
```

---

## Tailwind Classes Reference

### Glass Effect Classes
```css
.glass {
  background: rgba(10, 10, 10, 0.6);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.glass-hover {
  transition: all 0.3s ease-out;
}

.glass-hover:hover {
  border-color: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}
```

### Stamp Text Class
```css
.stamp {
  font-family: var(--font-mono, monospace);
  text-transform: uppercase;
  letter-spacing: 0.15em;
}
```

### Skeleton Animation
```css
.skeleton-steal {
  background: linear-gradient(90deg, 
    rgba(255,255,255,0.03) 0%,
    rgba(255,255,255,0.08) 50%,
    rgba(255,255,255,0.03) 100%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}
```

---

## Example Rendered States

### With Sample Data

**MuscleRadar:**
- BACK: 28% (14,500 KG)
- CHEST: 24% (12,200 KG) - *dominant*
- SHOULDERS: 18% (9,100 KG)
- ARMS: 15% (7,600 KG)
- LEGS: 15% (7,600 KG)

**MuscleBalance:**
- PUSH: 45% (22,500 KG) - *dominant*
- PULL: 30% (15,000 KG)
- LEGS: 25% (12,500 KG)

**PRWall (3 cards):**
1. Bench Press - 105KG e1RM (85KG × 5) - GOLD badge
2. Deadlift - 140KG e1RM (120KG × 3) - SPEED badge
3. Overhead Press - 72KG e1RM (60KG × 4) - FIRE badge

---

## Accessibility

- All charts include `aria-label` and `role` attributes
- Reduced motion preference respected via `@media (prefers-reduced-motion: reduce)`
- Color contrast meets WCAG AA standards
- Keyboard navigation supported for interactive elements
- Screen reader announcements for dynamic content via `aria-live`

---

## Performance Considerations

- Client-side mounting delay (80-120ms) prevents layout shift
- Memoized calculations via `useMemo` for derived data
- SVG rendering optimized with minimal path complexity
- Animations use `transform` and `opacity` for GPU acceleration
- `will-change` applied only to animated properties

---

## File Locations

```
src/
├── components/progress/
│   ├── MuscleRadar.tsx      # Pentagon radar chart
│   ├── MuscleBalance.tsx    # Push/pull/legs bars
│   └── PRWall.tsx           # Personal records cards
├── hooks/
│   └── useProgress.ts       # Data fetching hooks
├── types/
│   ├── progress.ts          # Progress data types
│   └── exercise.ts          # MuscleGroup type
└── app/(app)/progress/
    └── page.tsx             # Main progress page