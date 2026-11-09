import shipyard from '@levino/shipyard-base'
import shipyardDocs from '@levino/shipyard-docs'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig } from 'astro/config'
import appCss from './src/styles/app.css?url'

// Statische Seite für Cloudflare Pages. Das Einzige, was zur Laufzeit läuft,
// ist die Umfrage-API in functions/api/zeit.ts (Pages Function mit D1).
export default defineConfig({
  site: 'https://go-ag.levinkeller.de',
  // Cloudflare Pages erwartet die Ausgabe weiterhin in build/ (wie bei Docusaurus).
  outDir: './build',
  vite: { plugins: [tailwindcss()] },
  // Die Seite hat keine eigene Startseite: / und /infos zeigen auf „Über die Go-AG“.
  // Alte Docusaurus-Adressen leiten auf die neuen um (Links von der Schul-Webseite).
  redirects: {
    '/': '/infos/ueber-die-ag',
    '/infos': '/infos/ueber-die-ag',
    '/spielmaterial': '/infos/spielmaterial',
    '/online-go': '/infos/online-go',
    '/kifu': '/infos/kifu',
  },
  integrations: [
    shipyard({
      css: appCss,
      brand: 'Go-AG',
      title: 'Go-AG Freie Waldorfschule Hannover-Maschsee',
      tagline: 'Das ostasiatische Strategiespiel Go lernen und spielen',
      locale: 'de',
      onBrokenLinks: 'throw',
      navigation: {
        infos: { label: 'Informationen', href: '/infos/ueber-die-ag' },
        zeit: { label: 'Terminumfrage', href: '/zeit' },
        impressum: { label: 'Impressum', href: '/impressum' },
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Informationen',
            items: [
              { label: 'Über die Go-AG', to: '/infos/ueber-die-ag' },
              { label: 'Spielmaterial', to: '/infos/spielmaterial' },
              { label: 'Online Go', to: '/infos/online-go' },
              { label: 'Partieprotokoll', to: '/infos/kifu' },
              { label: 'Terminumfrage', to: '/zeit' },
            ],
          },
          {
            title: 'Rechtliches',
            items: [{ label: 'Impressum', to: '/impressum' }],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Levin Keller. Go-AG Freie Waldorfschule Hannover-Maschsee.`,
      },
    }),
    shipyardDocs({
      routeBasePath: 'infos',
      editUrl: 'https://github.com/levino/go-ag/edit/main/infos',
    }),
  ],
})
