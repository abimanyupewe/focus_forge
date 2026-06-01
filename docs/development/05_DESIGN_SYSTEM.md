# 🎨 05 — Design System

> **Fase:** 1 (Core Foundation)  
> **Prioritas:** 🔴 Critical  
> **Estimasi:** 3-4 jam  
> **Dependensi:** `01_PROJECT_SETUP.md`

---

## 1. Deskripsi

Design System lengkap FocusForge — color palette, typography, spacing, shape, dan theme (Light/Dark). Gaya visual: **Flat Design 2.0** — *Whitespace-heavy*, clean, dan minimalist.

---

## 2. Color Palette

### Light Mode

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `background` | `#F8F9FA` | Background utama |
| `surface` | `#FFFFFF` | Card, dialog |
| `surfaceVariant` | `#F1F3F5` | Input fields |
| `primary` | `#2B6CB0` | CTA, active states |
| `primaryContainer` | `#EBF4FF` | Primary tint |
| `secondary` | `#38A169` | Completion states |
| `error` | `#E53E3E` | Destructive actions |
| `onBackground` | `#1A202C` | Primary text |
| `onSurfaceVariant` | `#718096` | Hint text |
| `outline` | `#E2E8F0` | Borders |

### Dark Mode

| Token | Hex | Penggunaan |
|-------|-----|------------|
| `background` | `#121212` | Background utama |
| `surface` | `#1E1E1E` | Card |
| `primary` | `#63B3ED` | Lighter blue |
| `secondary` | `#68D391` | Lighter green |
| `onBackground` | `#F7FAFC` | Primary text |
| `outline` | `#4A5568` | Borders |

### Category Colors (Schedule Cards)

`#2B6CB0` Blue, `#38A169` Green, `#D69E2E` Amber, `#E53E3E` Red, `#805AD5` Purple, `#DD6B20` Orange, `#319795` Teal, `#D53F8C` Pink

---

## 3. Typography

**Font:** `Inter` (Google Fonts) — Fallback: `Nunito`, system sans-serif

| Token | Size | Weight | Penggunaan |
|-------|------|--------|------------|
| `displayLarge` | 32sp | Bold | Timer display |
| `headlineMedium` | 24sp | SemiBold | Page titles |
| `titleLarge` | 20sp | SemiBold | Section headers |
| `titleMedium` | 16sp | Medium | Card titles |
| `bodyLarge` | 16sp | Regular | Body text |
| `bodyMedium` | 14sp | Regular | Secondary text |
| `bodySmall` | 12sp | Regular | Captions |
| `labelLarge` | 14sp | SemiBold | Buttons |
| `labelSmall` | 11sp | Medium | Badges |

---

## 4. Spacing Scale (Base 4px)

| Token | Value | Penggunaan |
|-------|-------|------------|
| `xs` | 4px | Micro spacing |
| `sm` | 8px | Tight |
| `md` | 12px | Compact |
| `base` | 16px | Default |
| `lg` | 20px | Comfortable |
| `xl` | 24px | Roomy |
| `xxl` | 32px | Section spacing |
| `xxxl` | 48px | Page-level |

---

## 5. Shape System

| Token | Radius | Penggunaan |
|-------|--------|------------|
| `radiusSm` | 8px | Chips, badges |
| `radiusMd` | 12px | Cards, inputs |
| `radiusLg` | 16px | Bottom sheets |
| `radiusXl` | 24px | FAB |
| `radiusFull` | 999px | Circular |

---

## 6. Theme Configuration

- `AppTheme.light` dan `AppTheme.dark` sebagai `ThemeData`
- Material 3 enabled
- Card menggunakan **border-based elevation** (elevation 0 + outline border)
- Input fields menggunakan filled style dengan `surfaceVariant`
- BottomNavigationBar: `primary` untuk selected, `onSurfaceVariant` untuk unselected

---

## 7. Acceptance Criteria

- [ ] Light & Dark theme ter-apply via `MaterialApp`
- [ ] Semua komponen menggunakan token dari `AppColors` (bukan hardcoded)
- [ ] Typography konsisten via `AppTypography`
- [ ] Dark mode contrast ratio minimum 4.5:1 (WCAG AA)
- [ ] Cards menggunakan border (elevation 0) — Flat Design 2.0
