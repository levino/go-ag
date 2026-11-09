import { execFileSync } from 'node:child_process'
import { fileURLToPath } from 'node:url'
import type { APIRoute, GetStaticPaths } from 'astro'

// Die Partieprotokolle werden beim Build aus den Typst-Quellen im Repo-Wurzelverzeichnis
// erzeugt. `npm run build` installiert dafür vorher das typst-Binary.
const sizes = ['9', '13', '19'] as const

export const getStaticPaths = (() =>
  sizes.map((size) => ({
    params: { file: `kifu-${size}x${size}.pdf` },
    props: { source: `kifu${size}.typ` },
  }))) satisfies GetStaticPaths

export const GET: APIRoute = ({ props }) => {
  const source = fileURLToPath(new URL(`../../../${props.source}`, import.meta.url))
  const pdf = execFileSync('typst', ['compile', source, '-'], {
    maxBuffer: 10 * 1024 * 1024,
  })
  return new Response(pdf, { headers: { 'Content-Type': 'application/pdf' } })
}
