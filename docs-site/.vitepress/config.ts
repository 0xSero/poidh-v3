import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'POIDH v3',
  description: 'Secure bounty protocol with weighted voting and pull-payments',
  
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Architecture', link: '/architecture' },
      { text: 'State Machines', link: '/state-machines' },
      { text: 'Security', link: '/security' },
      { text: 'API', link: '/api' },
    ],

    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Introduction', link: '/' },
          { text: 'Architecture', link: '/architecture' },
          { text: 'State Machines', link: '/state-machines' },
          { text: 'Security', link: '/security' },
          { text: 'API Reference', link: '/api' },
          { text: 'Deployment', link: '/deployment' },
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/picsoritdidnthappen/poidh-contracts' }
    ],

    search: {
      provider: 'local'
    },

    // Dark mode by default
    darkMode: 'dark',
    
    // Clean, minimal appearance
    appearance: 'dark'
  },

  // Custom head for mermaid
  head: [
    ['script', { src: 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js' }]
  ],

  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    },
    config: (md) => {
      // Add support for mermaid diagrams
      md.use(require('markdown-it-mermaid'))
    }
  },

  // Vite config for custom styles
  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: `
            :root {
              --vp-c-brand-1: #6366f1;
              --vp-c-brand-2: #818cf8;
              --vp-home-hero-name-background: linear-gradient(120deg, #6366f1 0%, #818cf8 100%);
            }
          `
        }
      }
    }
  }
})
