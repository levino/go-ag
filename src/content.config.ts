import { createDocsCollection } from '@levino/shipyard-docs'
import { defineCollection } from 'astro:content'

const infos = defineCollection(createDocsCollection('./infos'))

export const collections = { infos }
