// Terminumfrage der Go-AG. Läuft zur Laufzeit im Worker und speichert in D1
// (Binding DB, siehe wrangler.jsonc). Tabelle und fehlende Tages-Spalten werden
// beim ersten Aufruf angelegt.
import type { APIRoute } from 'astro'
import { env } from 'cloudflare:workers'

export const prerender = false

// Zur Auswahl stehende Tage (jeweils 14–16 Uhr). Ein neuer Tag braucht nur hier
// einen Eintrag (und in src/pages/zeit.astro); die Spalte entsteht automatisch.
export const DAYS = ['montag', 'dienstag', 'freitag'] as const
type Day = (typeof DAYS)[number]

const CLASSES: ReadonlyArray<string> = [
  ...Array.from({ length: 13 }, (_, i) => `${i + 1}`),
  'eltern',
  'lehrkraft',
]

interface Vote {
  klasse: string
  vorname: string | null
  days: ReadonlyArray<Day>
}

type Tally = Record<Day, number> & { stimmen: number }

const CREATE_TABLE = `CREATE TABLE IF NOT EXISTS stimmen (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  erstellt TEXT NOT NULL DEFAULT (datetime('now')),
  klasse TEXT NOT NULL,
  vorname TEXT
)`

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  })

const parseVote = (form: FormData): Vote | string => {
  const klasse = String(form.get('klasse') ?? '')
  if (!CLASSES.includes(klasse)) {
    return 'Bitte wähle deine Klasse aus.'
  }
  const days = DAYS.filter((day) => form.getAll('tag').includes(day))
  if (days.length === 0) {
    return 'Bitte kreuze mindestens einen Tag an.'
  }
  const vorname = String(form.get('vorname') ?? '').trim().slice(0, 40)
  return { klasse, vorname: vorname === '' ? null : vorname, days }
}

const ensureSchema = async (db: D1Database) => {
  await db.prepare(CREATE_TABLE).run()
  const { results } = await db.prepare('PRAGMA table_info(stimmen)').all<{ name: string }>()
  const existing = new Set(results.map(({ name }) => name))
  const missing = DAYS.filter((day) => !existing.has(day))
  if (missing.length > 0) {
    await db.batch(
      missing.map((day) =>
        db.prepare(`ALTER TABLE stimmen ADD COLUMN ${day} INTEGER NOT NULL DEFAULT 0`),
      ),
    )
  }
}

// Einmal pro Worker-Instanz prüfen, nicht bei jeder Anfrage.
let schemaReady: Promise<void> | undefined

const withDb = async (run: (db: D1Database) => Promise<Response>): Promise<Response> => {
  schemaReady ??= ensureSchema(env.DB).catch((error: unknown) => {
    schemaReady = undefined
    throw error
  })
  await schemaReady
  return run(env.DB)
}

const tally = async (db: D1Database): Promise<Tally> => {
  const sums = DAYS.map((day) => `COALESCE(SUM(${day}), 0) AS ${day}`).join(', ')
  const row = await db.prepare(`SELECT COUNT(*) AS stimmen, ${sums} FROM stimmen`).first<Tally>()
  return row ?? (Object.fromEntries([['stimmen', 0], ...DAYS.map((day) => [day, 0])]) as Tally)
}

export const GET: APIRoute = () => withDb(async (db) => json(await tally(db)))

export const POST: APIRoute = ({ request, redirect }) =>
  withDb(async (db) => {
    const wantsJson = (request.headers.get('Accept') ?? '').includes('application/json')
    const vote = parseVote(await request.formData())
    if (typeof vote === 'string') {
      return wantsJson
        ? json({ fehler: vote }, 400)
        : redirect(`/zeit?fehler=${encodeURIComponent(vote)}`, 303)
    }
    await db
      .prepare(
        `INSERT INTO stimmen (klasse, vorname, ${DAYS.join(', ')}) VALUES (?, ?, ${DAYS.map(() => '?').join(', ')})`,
      )
      .bind(vote.klasse, vote.vorname, ...DAYS.map((day) => (vote.days.includes(day) ? 1 : 0)))
      .run()
    return wantsJson ? json(await tally(db)) : redirect('/zeit?danke=1', 303)
  })
