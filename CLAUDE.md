# Matt Bryan Portfolio Website

Personal portfolio website for Matt Bryan, PTA. Hosted on GitHub Pages with custom domain.

**Live URL**: https://mattbfit.net
**Repository**: https://github.com/bryanlabs/matt-website

---

## Hosting Architecture

### GitHub Pages (Static Hosting)

This site uses GitHub Pages for hosting. When you push to the `main` branch, GitHub automatically deploys the static files.

**How it works:**
1. Push changes to `main` branch
2. GitHub Pages detects the push
3. Static files are served from the repository root
4. The `CNAME` file tells GitHub Pages to use the custom domain

**No build step required** - this is a pure static site with vanilla HTML/CSS.

### SSL/TLS Certificates

SSL certificates are **automatically provisioned by GitHub Pages** via Let's Encrypt.

- GitHub handles certificate renewal automatically
- Certificates cover both `mattbfit.net` and `www.mattbfit.net`
- HTTPS is enforced by default

**If SSL issues occur:**
```bash
# Remove and re-add custom domain to trigger new certificate
gh api -X DELETE /repos/bryanlabs/matt-website/pages
gh api -X POST /repos/bryanlabs/matt-website/pages -f source='{"branch":"main","path":"/"}'
```

---

## Updating the Website

### Quick Update (Most Common)

```bash
cd /Users/danb/Documents/matt/matt-website

# Make your changes to HTML files
# Then commit and push:
git add .
git commit -m "Description of changes"
git push
```

Changes appear on the live site within 1-2 minutes.

### Using GitHub CLI

The `gh` CLI is used for GitHub operations:

```bash
# Check repository info
gh repo view bryanlabs/matt-website

# View recent deployments
gh api /repos/bryanlabs/matt-website/pages/builds

# Check Pages status
gh api /repos/bryanlabs/matt-website/pages
```

### Files Overview

| File | Purpose |
|------|---------|
| `index.html` | Main portfolio page |
| `resume.html` | Professional resume |
| `resume.docx` | Styled Word export (auto-generated from resume.html) |
| `neuroworks.html` | Hidden cover letter page |
| `headshot.jpg` | Profile photo |
| `instagram_*.mp4` | Training showcase videos |
| `CNAME` | Custom domain configuration |
| `Dockerfile` | Container build (for alternative deployment) |
| `scripts/build-resume-docx.py` | Converts resume.html to styled DOCX using python-docx |
| `.github/workflows/convert-resume.yml` | Auto-regenerates resume.docx on push |

---

## DNS Configuration (AWS Route 53)

### Authentication

```bash
# Authenticate to AWS (bryanlabs profile)
aws-auth --profile bryanlabs --fresh

# Verify authentication
aws sts get-caller-identity
```

### Finding Hosted Zone

```bash
# List all hosted zones
aws route53 list-hosted-zones

# The mattbfit.net hosted zone ID is: Z055294918CC67E93SFCG
```

### Current DNS Records

```bash
# View all records for mattbfit.net
aws route53 list-resource-record-sets --hosted-zone-id Z055294918CC67E93SFCG
```

**Required records for GitHub Pages:**

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | mattbfit.net | 185.199.108.153 | 300 |
| A | mattbfit.net | 185.199.109.153 | 300 |
| A | mattbfit.net | 185.199.110.153 | 300 |
| A | mattbfit.net | 185.199.111.153 | 300 |
| CNAME | www.mattbfit.net | bryanlabs.github.io | 300 |

### Updating DNS Records

```bash
# Create a change batch JSON file
cat > /tmp/dns-change.json << 'EOF'
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "mattbfit.net",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [
          {"Value": "185.199.108.153"},
          {"Value": "185.199.109.153"},
          {"Value": "185.199.110.153"},
          {"Value": "185.199.111.153"}
        ]
      }
    }
  ]
}
EOF

# Apply the change
aws route53 change-resource-record-sets \
  --hosted-zone-id Z055294918CC67E93SFCG \
  --change-batch file:///tmp/dns-change.json
```

### TTL Guidelines

| Scenario | Recommended TTL |
|----------|-----------------|
| Active development/testing | 60-300 seconds |
| Stable production | 3600 seconds (1 hour) |
| Rarely changing records | 86400 seconds (24 hours) |

### DNS Verification

```bash
# Check A records
dig mattbfit.net A +short

# Check CNAME
dig www.mattbfit.net CNAME +short

# Full DNS trace
dig mattbfit.net +trace
```

---

## Design System & Branding

### Tech Stack

- **HTML5** - Semantic markup
- **Vanilla CSS** - No frameworks (not Tailwind, Bootstrap, etc.)
- **CSS Custom Properties** - For theming consistency
- **Google Fonts** - Montserrat typeface
- **No JavaScript frameworks** - Pure static HTML

### Color Palette

All colors are defined as CSS custom properties in `:root`:

```css
:root {
    --primary: #0D6E6E;    /* Deep teal - main brand color */
    --secondary: #14919B;  /* Lighter teal - accents and hover states */
    --accent: #1A3A3A;     /* Dark teal - footer, contact section */
    --light: #E8F4F4;      /* Very light teal - backgrounds, cards */
    --dark: #2C3E50;       /* Dark blue-gray - body text */
    --white: #FFFFFF;      /* Pure white */
    --gradient: linear-gradient(135deg, #0D6E6E 0%, #14919B 50%, #1A3A3A 100%);
}
```

**Color Usage Guidelines:**

| Color | Usage |
|-------|-------|
| `--primary` | Headers, links, buttons, borders, key UI elements |
| `--secondary` | Hover states, secondary buttons, accents |
| `--accent` | Footer background, contact section, dark sections |
| `--light` | Card backgrounds, alternating sections, subtle backgrounds |
| `--dark` | Body text, paragraphs |
| `--white` | Page background, text on dark backgrounds |
| `--gradient` | Hero section, showcase section backgrounds |

### Typography

**Font Family:** Montserrat (Google Fonts)

```css
font-family: 'Montserrat', sans-serif;
```

**Font Weights Used:**
- 300 (Light) - Subtitles, secondary text
- 400 (Regular) - Body text
- 600 (Semi-bold) - Buttons, labels
- 700 (Bold) - Section titles, emphasis
- 800 (Extra-bold) - Hero name, major headings

**Font Sizing:**
- Uses `clamp()` for responsive sizing
- Hero h1: `clamp(2.5rem, 8vw, 5rem)`
- Subtitles: `clamp(1rem, 3vw, 1.5rem)`
- Body: `0.9rem - 1.1rem`

### Layout Patterns

**Section Structure:**
```css
section {
    padding: 6rem 2rem;  /* Consistent vertical rhythm */
}
```

**Max Widths:**
- Content containers: `max-width: 900px` or `1000px`
- Video grid: `max-width: 1200px`
- Docs grid: `max-width: 800px`

**Grid Patterns:**
```css
/* Responsive card grids */
grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
gap: 2rem;
```

### Component Styles

**Buttons:**
```css
.btn {
    padding: 1rem 2.5rem;
    font-size: 1rem;
    font-weight: 600;
    border-radius: 50px;      /* Pill-shaped */
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.3s ease;
}
```

**Cards:**
```css
.credential-card, .doc-card {
    background: var(--light);
    padding: 2rem;
    border-radius: 15px;
    transition: transform 0.3s ease;
}
/* Hover: translateY(-5px) lift effect */
```

**Shadows:**
- Cards: `box-shadow: 0 10px 40px rgba(0,0,0,0.1)`
- Headshot: `box-shadow: 0 10px 40px rgba(0,0,0,0.3)`
- Buttons hover: `box-shadow: 0 10px 30px rgba(0,0,0,0.2)`

### Section Alternation

Sections alternate between light and dark backgrounds:

1. **Hero** - Gradient background (--gradient)
2. **Stats** - White background
3. **About** - Light background (--light)
4. **Credentials** - White background
5. **Showcase** - Gradient background (--gradient)
6. **Resume** - White background
7. **Contact** - Accent background (--accent)
8. **Footer** - Black (#111)

### Responsive Breakpoints

```css
@media (max-width: 768px) {
    /* Tablet and below */
}

@media (max-width: 600px) {
    /* Mobile */
}
```

### Animation

**Subtle animations only:**
- Hero background: Slow floating circles (20s infinite)
- Hover transitions: `transition: all 0.3s ease`
- Card lifts: `transform: translateY(-5px)`

---

## Docker (Alternative Deployment)

A Dockerfile exists for containerized deployment (e.g., Kubernetes):

```bash
# Build
docker build -t matt-website .

# Run locally
docker run -p 8080:80 matt-website

# Access at http://localhost:8080
```

The GitHub Actions workflow builds and pushes to GHCR on every push to main.

---

## Quick Reference

```bash
# Authenticate to AWS
aws-auth --profile bryanlabs --fresh

# Check site is live
curl -I https://mattbfit.net

# View DNS records
aws route53 list-resource-record-sets --hosted-zone-id Z055294918CC67E93SFCG

# Deploy changes
git add . && git commit -m "message" && git push

# Check GitHub Pages status
gh api /repos/bryanlabs/matt-website/pages
```
