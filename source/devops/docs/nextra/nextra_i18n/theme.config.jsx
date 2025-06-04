import React from 'react'
import { DocsThemeConfig } from 'nextra-theme-docs'

const config: DocsThemeConfig = {
  logo: <span>Cloud Atlas: Architecture</span>,
  project: {
    link: 'https://github.com/huataihuang/cloud-atlas.dev_arch',
  },
  chat: {
    link: 'https://discord.com',
  },
  docsRepositoryBase: 'https://github.com/huataihuang/cloud-atlas.dev_arch',
  footer: {
    text: 'Cloud Atlas by Huatai Huang',
  },
}

i18n: [
  { locale: 'en', name: 'English' },
  { locale: 'zh', name: '中文' }
]
